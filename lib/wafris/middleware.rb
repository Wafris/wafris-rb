# frozen_string_literal: true

module Wafris
  class Middleware
    def initialize(app)
      @app = app
      ProxyFilter.set_filter
    end

    def call(env)
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
