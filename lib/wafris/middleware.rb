
# frozen_string_literal: true

require 'wafris'

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
      ip = request.ip.force_encoding('UTF-8')
      user_agent = request.user_agent.force_encoding('UTF-8')
      path = request.path.force_encoding('UTF-8')    
      parameters = Rack::Utils.build_query(request.params).force_encoding('UTF-8')
      host = request.host.to_s.force_encoding('UTF-8')      
      request_method = String.new(request.request_method).force_encoding('UTF-8')
      
      # Submitted for evaluation
      treatment = Wafris.evaluate(ip, user_agent, path, parameters, host, request_method)

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

      LogSuppressor.puts_log "[Wafris] Error in Middleware: #{e.message}"
      @app.call(env)

    end
  end
end
