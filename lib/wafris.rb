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
    attr_accessor :configuration

    def configure
      raise ArgumentError, "[Wafris] block is required to configure Wafris" unless block_given?

      self.configuration ||= Wafris::Configuration.new
      yield(configuration)
      LogSuppressor.puts_log(
        "[Wafris] attempting firewall connection via Wafris.configure initializer."
      )
      configuration.create_settings
    rescue Redis::CannotConnectError, ArgumentError
      LogSuppressor.puts_log(
        "[Wafris] firewall disabled. Cannot connect via Wafris.configure. Please check your configuration settings."
      )
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
