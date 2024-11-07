# This file includes code from the https://github.com/rack/rack project,
# which is licensed under the MIT License.
# Copyright (C) 2007-2021 Leah Neukirchen <http://leahneukirchen.org/infopage.html>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# frozen_string_literal: true

module Wafris
  module ProxyFilter
    def self.set_filter
      user_defined_proxies = ENV["TRUSTED_PROXY_RANGES"].split(",") if ENV["TRUSTED_PROXY_RANGES"]

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
        /\A108\.162\.192#{valid_ipv4_octet}\z/,                   # 108.162.192.0/18
        /\A162\.15[8-9]#{valid_ipv4_octet}{2}\z/,                # 162.158.0.0/15
        /\A172\.(6[4-9]|7[0-1])#{valid_ipv4_octet}{2}\z/,         # 172.64.0.0/13
        *user_defined_proxies
      )

      Rack::Request.ip_filter = lambda { |ip| trusted_proxies.match?(ip) }
    end
  end
end
