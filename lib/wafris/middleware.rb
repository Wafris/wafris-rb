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
        # Cloudflare IPs: https://www.cloudflare.com/en-au/ips/
        /\A103\.21\.24[4-7]#{valid_ipv4_octet}\z/,                # 103.21.244.0/22
        /\A103\.22\.20[0-3]#{valid_ipv4_octet}\z/,                # 103.22.200.0/22
        /\A103\.31\.[4-7]#{valid_ipv4_octet}\z/,                  # 103.31.4.0/22
        /\A104\.(1[6-9]|2[0-3])#{valid_ipv4_octet}{2}\z/,         # 104.16.0.0/13
        /\A104\.2[4-7]#{valid_ipv4_octet}{2}\z/,                  # 104.24.0.0/14
        /\A108\.162\.(19[2-9]|2[0-4]\d|25[0-5])#{valid_ipv4_octet}\z/, # 108.162.192.0/18
        /\A131\.0\.7[2-5]#{valid_ipv4_octet}\z/,                  # 131.0.72.0/22
        /\A141\.101\.(6[4-9]|[7-9]\d|1[0-1]\d|12[0-3])#{valid_ipv4_octet}\z/, # 141.101.64.0/18
        /\A162\.15[8-9]#{valid_ipv4_octet}{2}\z/,                 # 162.158.0.0/15
        /\A172\.(6[4-9]|7[0-1])#{valid_ipv4_octet}{2}\z/,         # 172.64.0.0/13
        /\A173\.245\.(4[8-9]|5\d|6[0-3])#{valid_ipv4_octet}\z/,   # 173.245.48.0/20
        /\A188\.114\.(9[6-9]|10\d|11[0-1])#{valid_ipv4_octet}\z/, # 188.114.96.0/20
        /\A190\.93\.2[4-5]\d#{valid_ipv4_octet}\z/,               # 190.93.240.0/20
        /\A197\.234\.24[0-3]#{valid_ipv4_octet}\z/,               # 197.234.240.0/22
        /\A198\.41\.(12[8-9]|1[3-9]\d|2[0-5]\d)#{valid_ipv4_octet}\z/, # 198.41.128.0/17
        *user_defined_proxies
      )

      Rack::Request.ip_filter = lambda { |ip| trusted_proxies.match?(ip) }

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
