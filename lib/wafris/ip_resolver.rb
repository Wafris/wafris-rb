# frozen_string_literal: true

module Wafris
  class IpResolver
    # List of possible IP headers in order of priority
    IP_HEADERS = %w[
      HTTP_X_REAL_IP
      HTTP_X_TRUE_CLIENT_IP
      HTTP_FLY_CLIENT_IP
      HTTP_CF_CONNECTING_IP
    ].freeze

    def initialize(request)
      @request_env = request.env
      @ip = request.ip
    end

    def resolve
      return @request_env[ip_header] if ip_header

      @ip
    end

    private

    def ip_header
      IP_HEADERS.find { |header| @request_env[header] }
    end
  end
end
