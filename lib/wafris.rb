# frozen_string_literal: true

require 'connection_pool'
require 'rails'
require 'redis'

require 'wafris/configuration'
require 'wafris/middleware'

require 'wafris/railtie' if defined?(Rails::Railtie)

module Wafris
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Wafris::Configuration.new
    end

    def reset
      @configuration = Wafris::Configuration.new
    end

    # ip: the IP of the client making the request, may be from x-forwarded-for
    # user_agent: full user agent making the request
    # path: path including parameters of the request
    # host: host (website/domain) making the request
    # time: UTC time of the request (from the logs to match things up)

    def allow_request?(request)
      configuration.connection_pool.with do |conn|
        time = Time.now
        status = conn.evalsha(
          configuration.script_sha,
          argv: [
            request.ip,
            IPAddr.new(request.ip).to_i,
            time.to_i,
            "all-ips:#{time.strftime('%Y-%m-%d')}:#{time.hour}"
          ]
        )

        if status.eql? 'Blocked'
          return false
        else
          return true
        end
      end
    end
  end
end
