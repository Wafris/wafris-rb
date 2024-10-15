require_relative "version"

module Wafris
  class Configuration
    attr_accessor :api_key
    attr_accessor :db_file_path
    attr_accessor :db_file_name
    attr_accessor :downsync_custom_rules_interval
    attr_accessor :downsync_data_subscriptions_interval
    attr_accessor :downsync_url
    attr_accessor :upsync_url
    attr_accessor :upsync_interval
    attr_accessor :upsync_queue_limit
    attr_accessor :upsync_status
    attr_accessor :upsync_queue
    attr_accessor :local_only
    attr_accessor :last_upsync_timestamp
    attr_accessor :max_body_size_mb
    attr_accessor :rate_limiters

    def initialize
      # API Key - Required
      if ENV["WAFRIS_API_KEY"]
        @api_key = ENV["WAFRIS_API_KEY"]
      else
        unless @api_key
          LogSuppressor.puts_log("Firewall disabled as neither local only or API key set")
        end
      end

      # DB FILE PATH LOCATION - Optional
      @db_file_path = ENV["WAFRIS_DB_FILE_PATH"] || "./tmp/wafris"

      # Ensure that the db_file_path exists
      unless File.directory?(@db_file_path)
        LogSuppressor.puts_log("DB File Path does not exist - creating it now.")
        FileUtils.mkdir_p(@db_file_path) unless File.exist?(@db_file_path)
      end

      # DB FILE NAME - For local
      @db_file_name = ENV["WAFRIS_DB_FILE_NAME"] || "wafris.db"

      # DOWNSYNC
      # Custom Rules are checked often (default 1 minute) - Optional
      @downsync_custom_rules_interval = ENV["WAFRIS_DOWNSYNC_CUSTOM_RULES_INTERVAL"]&.to_i || 60

      # Data Subscriptions are checked rarely (default 1 day) - Optional
      @downsync_data_subscriptions_interval = ENV["WAFRIS_DOWNSYNC_DATA_SUBSCRIPTIONS_INTERVAL"]&.to_i || 60

      # Set Downsync URL - Optional
      # Used for both DataSubscription and CustomRules
      @downsync_url = ENV["WAFRIS_DOWNSYNC_URL"] || "https://distributor.wafris.org/v2/downsync"

      # UPSYNC - Optional
      # Set Upsync URL
      @upsync_url = ENV["WAFRIS_UPSYNC_URL"] || "https://collector.wafris.org/v2/upsync"

      # Set Upsync Interval - Optional
      @upsync_interval = ENV["WAFRIS_UPSYNC_INTERVAL"]&.to_i || 10

      # Set Upsync Queued Request Limit - Optional
      @upsync_queue_limit = ENV["WAFRIS_UPSYNC_QUEUE_LIMIT"]&.to_i || 250

      # Set Maximium Body Size for Requests - Optional (in Megabytes)
      @max_body_size_mb = if ENV["WAFRIS_MAX_BODY_SIZE_MB"] && ENV["WAFRIS_MAX_BODY_SIZE_MB"].to_i > 0
                            ENV["WAFRIS_MAX_BODY_SIZE_MB"].to_i
                          else
                            10
                          end

      # Upsync Queue Defaults
      @upsync_queue = []
      @last_upsync_timestamp = Time.now.to_i

      # Memory structure for rate limiting
      @rate_limiters = {}

      # Disable Upsync if Downsync API Key is invalid
      # This prevents the client from sending upsync requests
      # if the API key is known bad
      @upsync_status = "Disabled"
    end

    def current_config
      output = {}

      instance_variables.each do |var|
        output[var.to_s] = instance_variable_get(var)
      end

      output
    end

    def create_settings
      @version = Wafris::VERSION
    end
  end
end
