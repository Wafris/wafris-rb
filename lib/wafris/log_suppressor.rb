# frozen_string_literal: true

module Wafris
  class LogSuppressor
    def self.puts_log(message)
      puts("[Wafris] " + message) unless suppress_logs?
    end

    def self.suppress_logs?
      suppressed_environments.include?(current_environment) ||
        (ENV["WAFRIS_LOG_LEVEL"] && ENV["WAFRIS_LOG_LEVEL"] == "silent")
    end

    def self.suppressed_environments
      ["test"] + (ENV["CI"] ? ["CI"] : [])
    end

    def self.current_environment
      if defined?(Rails)
        Rails.env
      else
        ENV["RACK_ENV"] || "development"
      end
    end
  end
end
