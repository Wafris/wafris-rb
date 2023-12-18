# frozen_string_literal: true

module Wafris
  class Middleware
    TRUSTED_PROXY_RANGES = ENV.fetch('TRUSTED_PROXY_RANGES', '').split(',').freeze

    VALID_IPV4_OCTET = /\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])/

    TRUSTED_PROXIES = Regexp.union(
      /\A127#{VALID_IPV4_OCTET}{3}\z/,                          # localhost IPv4 range 127.x.x.x, per RFC-3330
      /\A::1\z/,                                                # localhost IPv6 ::1
      /\Af[cd][0-9a-f]{2}(?::[0-9a-f]{0,4}){0,7}\z/i,           # private IPv6 range fc00 .. fdff
      /\A10#{VALID_IPV4_OCTET}{3}\z/,                           # private IPv4 range 10.x.x.x
      /\A172\.(1[6-9]|2[0-9]|3[01])#{VALID_IPV4_OCTET}{2}\z/,   # private IPv4 range 172.16.0.0 .. 172.31.255.255
      /\A192\.168#{VALID_IPV4_OCTET}{2}\z/,                     # private IPv4 range 192.168.x.x
      /\Alocalhost\z|\Aunix(\z|:)/i,                            # localhost hostname, and unix domain sockets
      *TRUSTED_PROXY_RANGES
    )

    def initialize(app)
      @app = app
    end

    def call(env)
      Rack::Request.ip_filter = lambda { |ip| TRUSTED_PROXIES.match?(ip) }

      request = Rack::Request.new(env)

      if Wafris.allow_request?(request)
        @app.call(env)
      else
        LogSuppressor.puts_log(
          "[Wafris] Blocked: #{request.ip} #{request.request_method} #{request.host} #{request.url}}"
        )
        [403, {}, ['Blocked']]
      end
    rescue Redis::TimeoutError
      LogSuppressor.puts_log(
        "[Wafris] Wafris timed out during processing. Request passed without rules check."
      )
      @app.call(env)
    rescue StandardError => e
      LogSuppressor.puts_log(
        "[Wafris] Redis connection error: #{e.message}. Request passed without rules check."
      )
      @app.call(env)
    end
  end
end
