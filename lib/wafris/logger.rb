module Wafris
  class Logger
    SKIPPED_ENVIRONMENTS = %w[test CI].freeze
    CURRENT_ENVIRONMENT = if defined?(Rails)
                            Rails.env
                          else
                            ENV['RACK_ENV'] || 'development'
                          end.freeze

    attr_accessor :quiet_mode

    def initialize(quiet_mode = false)
      @quiet_mode = quiet_mode
    end

    def info(message)
      return if quiet_mode
      return if SKIPPED_ENVIRONMENTS.include?(CURRENT_ENVIRONMENT)

      puts message
    end

    def self.info(message)
      return if SKIPPED_ENVIRONMENTS.include?(CURRENT_ENVIRONMENT)

      puts message
    end
  end
end
