# frozen_string_literal: true

require 'connection_pool'
require 'rails'
require 'redis'

require 'wafris/configuration'
require 'wafris/middleware'
require 'wafris/log_suppressor'

require 'wafris/railtie' if defined?(Rails::Railtie)

module Wafris
  class << self
    def configure
      yield configuration
      puts "[Wafris] attempting firewall connection via Wafris.configure initializer." unless LogSuppressor.suppress_logs?
      configuration.create_settings
    rescue Redis::CannotConnectError
      puts "[Wafris] firewall disabled. Cannot connect via Wafris.configure. Please check your configuration settings." unless LogSuppressor.suppress_logs?
    end

    def configuration
      @configuration ||= Wafris::Configuration.new
    end

    def reset
      @configuration = Wafris::Configuration.new
    end

    def allow_request?(request)
      configuration.connection_pool.with do |conn|
        time = Time.now.utc.to_i * 1000
        status = conn.evalsha(
          configuration.core_sha,
          argv: [
            request.ip,
            IPAddr.new(request.ip).to_i,
            time,
            request.user_agent,
            request.path,
            request.query_string,
            request.host,
            request.request_method
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
