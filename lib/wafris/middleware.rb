# frozen_string_literal: true


module Wafris
  class Middleware
    def initialize(app)
      @app = app
    end


    def call(env)

      user_defined_proxies = ENV['TRUSTED_PROXY_RANGES'].split(',') if ENV['TRUSTED_PROXY_RANGES']

      valid_ipv4_octet = /\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])/

      trusted_proxies = Regexp.union(
        /\A127#{valid_ipv4_octet}{3}\z/,                          # localhost IPv4 range 127.x.x.x, per RFC-3330
        /\A::1\z/,                                                # localhost IPv6 ::1
        /\Af[cd][0-9a-f]{2}(?::[0-9a-f]{0,4}){0,7}\z/i,           # private IPv6 range fc00 .. fdff
        /\A10#{valid_ipv4_octet}{3}\z/,                           # private IPv4 range 10.x.x.x
        /\A172\.(1[6-9]|2[0-9]|3[01])#{valid_ipv4_octet}{2}\z/,   # private IPv4 range 172.16.0.0 .. 172.31.255.255
        /\A192\.168#{valid_ipv4_octet}{2}\z/,                     # private IPv4 range 192.168.x.x
        /\Alocalhost\z|\Aunix(\z|:)/i,                            # localhost hostname, and unix domain sockets
        *user_defined_proxies
      )

      Rack::Request.ip_filter = lambda { |ip| trusted_proxies.match?(ip) }

      request = Rack::Request.new(env)
      # Forcing UTF-8 encoding on all strings for Sqlite3 compatibility

      # List of possible IP headers in order of priority
      ip_headers = [
        'HTTP_X_REAL_IP',
        'HTTP_X_TRUE_CLIENT_IP',
        'HTTP_FLY_CLIENT_IP',
        'HTTP_CF_CONNECTING_IP'
      ]

      # Find the first header that is present in the environment
      ip_header = ip_headers.find { |header| env[header] }

      # Use the found header or fallback to remote_ip if none of the headers are present
      ip = (ip_header ? env[ip_header] : request.ip).dup.force_encoding('UTF-8')

      user_agent = request.user_agent&.dup&.force_encoding('UTF-8')
      path = request.path.dup.force_encoding('UTF-8')
      parameters = Rack::Utils.build_query(request.params).force_encoding('UTF-8')
      host = request.host.to_s.dup.force_encoding('UTF-8')
      request_method = request.request_method.dup.force_encoding('UTF-8')

      # Submitted for evaluation
      headers = env.each_with_object({}) { |(k, v), h| h[k] = v.dup.force_encoding('UTF-8') if k.start_with?('HTTP_') }
      body = request.body.read

      request_id = env.fetch('action_dispatch.request_id', SecureRandom.uuid.to_s)
      request_timestamp = Time.now.utc.to_i

      treatment = Wafris.evaluate(ip, user_agent, path, parameters, host, request_method, headers, body, request_id, request_timestamp)

      # These values match what the client tests expect (200, 404, 403, 500
      if treatment == 'Allowed' || treatment == 'Passed'
        @app.call(env)
      elsif treatment == 'Blocked'
        [403, { 'content-type' => 'text/plain' }, ['Blocked']]
      else
        #ap request
        [500, { 'content-type' => 'text/plain' }, ['Error']]
      end

    rescue StandardError => e

      LogSuppressor.puts_log "[Wafris] Detailed Error: #{e.class} - #{e.message}"
      LogSuppressor.puts_log "[Wafris] Backtrace: #{e.backtrace.join("\n")}"
      @app.call(env)

    end
  end
end
