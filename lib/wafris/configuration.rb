# frozen_string_literal: true

require_relative "version"

module Wafris
  class Configuration
    attr_accessor :api_key,
                  :db_file_path,
                  :db_file_name,
                  :downsync_custom_rules_interval,
                  :downsync_data_subscriptions_interval,
                  :downsync_url,
                  :upsync_url,
                  :upsync_interval,
                  :upsync_queue_limit,
                  :upsync_status,
                  :upsync_queue,
                  :local_only,
                  :last_upsync_timestamp,
                  :max_body_size_mb,
                  :rate_limiters

    def initialize
      @api_key = ENV["WAFRIS_API_KEY"]
      @db_file_path = ENV["WAFRIS_DB_FILE_PATH"] || "./tmp/wafris"
      @db_file_name = ENV["WAFRIS_DB_FILE_NAME"] || "wafris.db"
      @downsync_custom_rules_interval = ENV["WAFRIS_DOWNSYNC_CUSTOM_RULES_INTERVAL"]&.to_i || 60
      @downsync_data_subscriptions_interval = ENV["WAFRIS_DOWNSYNC_DATA_SUBSCRIPTIONS_INTERVAL"]&.to_i || 60
      @downsync_url = ENV["WAFRIS_DOWNSYNC_URL"] || "https://distributor.wafris.org/v2/downsync"
      @upsync_url = ENV["WAFRIS_UPSYNC_URL"] || "https://collector.wafris.org/v2/upsync"
      @upsync_interval = ENV["WAFRIS_UPSYNC_INTERVAL"]&.to_i || 10
      @upsync_queue_limit = ENV["WAFRIS_UPSYNC_QUEUE_LIMIT"]&.to_i || 250
      @max_body_size_mb = set_max_body_size
      @upsync_queue = []
      @last_upsync_timestamp = Time.now.to_i
      @rate_limiters = {}
      @upsync_status = "Disabled"
    end

    def setup
      if @api_key
        create_db_file_path
      else
        LogSuppressor.puts_log("Firewall disabled as API key is not set.")
      end
    end

    private

    def set_max_body_size
      if ENV["WAFRIS_MAX_BODY_SIZE_MB"] && ENV["WAFRIS_MAX_BODY_SIZE_MB"].to_i > 0
        ENV["WAFRIS_MAX_BODY_SIZE_MB"].to_i
      else
        10
      end
    end

    def create_db_file_path
      # Ensure that the db_file_path exists
      unless File.directory?(@db_file_path)
        LogSuppressor.puts_log("DB File Path does not exist - creating it now.")
        FileUtils.mkdir_p(@db_file_path) unless File.exist?(@db_file_path)
      end
    end
  end
end
