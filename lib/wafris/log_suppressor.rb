# frozen_string_literal: true

module Wafris
  class LogSuppressor
    def self.suppress_logs?
      suppressed_environments.include?(current_environment)
    end

    def self.suppressed_environments
      ['development', 'test'] + (ENV['CI'] ? ['CI'] : [])
    end

    def self.current_environment
      if defined?(Rails)
        Rails.env
      else
        ENV['RACK_ENV'] || 'development'
      end
    end
  end
end
