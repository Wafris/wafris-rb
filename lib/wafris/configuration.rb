
require_relative 'version'

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
      if ENV['WAFRIS_API_KEY']
        @api_key = ENV['WAFRIS_API_KEY']        
      else
        @api_key = nil
        LogSuppressor.puts_log("Firewall disabled as neither local only or API key set")        
      end

      # DB FILE PATH LOCATION - Optional
      if ENV['WAFRIS_DB_FILE_PATH']
        @db_file_path = ENV['WAFRIS_DB_FILE_PATH']      
      else
        #@db_file_path = Rails.root.join('tmp', 'wafris').to_s
        @db_file_path = './tmp/wafris'
      end

      # Ensure that the db_file_path exists
      unless File.directory?(@db_file_path)
        LogSuppressor.puts_log("DB File Path does not exist - creating it now.")
        FileUtils.mkdir_p(@db_file_path) unless File.exist?(@db_file_path)
      end

      # DB FILE NAME - For local
      if ENV['WAFRIS_DB_FILE_NAME']
        @db_file_name = ENV['WAFRIS_DB_FILE_NAME']
      else
        @db_file_name = 'wafris.db'
      end
  
      # DOWNSYNC
      # Custom Rules are checked often (default 1 minute) - Optional
      if ENV['WAFRIS_DOWNSYNC_CUSTOM_RULES_INTERVAL']
        @downsync_custom_rules_interval = ENV['WAFRIS_DOWNSYNC_CUSTOM_RULES_INTERVAL'].to_i
      else
        @downsync_custom_rules_interval = 60
      end
  
      # Data Subscriptions are checked rarely (default 1 day) - Optional
      if ENV['WAFRIS_DOWNSYNC_DATA_SUBSCRIPTIONS_INTERVAL'] 
        @downsync_data_subscriptions_interval = ENV['WAFRIS_DOWNSYNC_DATA_SUBSCRIPTIONS_INTERVAL'].to_i
      else
        @downsync_data_subscriptions_interval = 86400
      end
  
      # Set Downsync URL - Optional
      # Used for both DataSubscription and CustomRules
      if ENV['WAFRIS_DOWNSYNC_URL']
        @downsync_url = ENV['WAFRIS_DOWNSYNC_URL']
      else
        @downsync_url = 'https://distributor.wafris.org/v2/downsync'
      end
      
      # UPSYNC - Optional
      # Set Upsync URL
      if ENV['WAFRIS_UPSYNC_URL']
        @upsync_url = ENV['WAFRIS_UPSYNC_URL']
      else
        @upsync_url = 'https://collector.wafris.org/v2/upsync' 
      end
  
      # Set Upsync Interval - Optional
      if ENV['WAFRIS_UPSYNC_INTERVAL']
        @upsync_interval = ENV['WAFRIS_UPSYNC_INTERVAL'].to_i
      else
        @upsync_interval = 60
      end
    
      # Set Upsync Queued Request Limit - Optional
      if ENV['WAFRIS_UPSYNC_QUEUE_LIMIT']
        @upsync_queue_limit = ENV['WAFRIS_UPSYNC_QUEUE_LIMIT'].to_i
      else
        @upsync_queue_limit = 1000
      end
  
      # Set Maximium Body Size for Requests - Optional (in Megabytes)
      if ENV['WAFRIS_MAX_BODY_SIZE_MB'] && ENV['WAFRIS_MAX_BODY_SIZE_MB'].to_i > 0  
        @max_body_size_mb = ENV['WAFRIS_MAX_BODY_SIZE_MB'].to_i
      else
        @max_body_size_mb = 10
      end

      # Upsync Queue Defaults
      @upsync_queue = []
      @last_upsync_timestamp = Time.now.to_i
  
      # Memory structure for rate limiting
      @rate_limiters = {}
  
      # Disable Upsync if Downsync API Key is invalid
      # This prevents the client from sending upsync requests
      # if the API key is known bad
      @upsync_status = 'Disabled'

      return true
  
    end

    def current_config

      output = {}

      instance_variables.each do |var|
        output[var.to_s] = instance_variable_get(var)
      end

      return output

    end

    def create_settings
      @version = Wafris::VERSION
    end

  end
end
