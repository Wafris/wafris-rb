# frozen_string_literal: true

require 'test_helper'
require 'awesome_print'

module Wafris
  describe Configuration do

    before do
      # Reset environment variables before each test
      reset_environment_variables
      @config = Configuration.new
    end

    after do
      # Clean up or reset environment variables after each test
      reset_environment_variables
    end

    describe "#initialize" do

      it "allows setting attributes with a block" do        
        @config.api_key = 'some_api_key'
        @config.db_file_path = "/some/path"        
        @config.db_file_name = "wafris.db"
        @config.downsync_custom_rules_interval = 600
        @config.downsync_data_subscriptions_interval = 864
        @config.downsync_url = 'https://example.com/v2/downsync'
        @config.upsync_url = 'https://example.com/v2/upsync'
        @config.upsync_interval = 600
        @config.upsync_queue_limit = 10

        # Custom values are set        
        _(@config.api_key).must_equal "some_api_key"
        _(@config.db_file_path).must_equal "/some/path"        
        _(@config.db_file_name).must_equal "wafris.db"
        _(@config.downsync_custom_rules_interval).must_equal 600
        _(@config.downsync_data_subscriptions_interval).must_equal 864
        _(@config.downsync_url).must_equal 'https://example.com/v2/downsync'
        _(@config.upsync_url).must_equal 'https://example.com/v2/upsync'
        _(@config.upsync_interval).must_equal 600
        _(@config.upsync_queue_limit).must_equal 10
      end

      it "sets default values" do        
        
        _(@config.api_key).must_be_nil
        _(@config.db_file_path).must_equal './tmp/wafris'
        _(@config.db_file_name).must_equal 'wafris.db'
        _(@config.downsync_custom_rules_interval).must_equal 60
        _(@config.downsync_data_subscriptions_interval).must_equal 86400
        _(@config.downsync_url).must_equal 'https://distributor.wafris.org/v2/downsync'
        _(@config.upsync_url).must_equal 'https://collector.wafris.org/v2/upsync'
        _(@config.upsync_interval).must_equal 60
        _(@config.upsync_queue_limit).must_equal 1000

      end

      it "config setting takes precedence over env var setting" do


        # Set API Key via ENV
        ENV['WAFRIS_API_KEY'] = '1234'
        @env_config = Configuration.new
        _(@env_config.api_key).must_equal '1234'

        # Override with config setting
        @env_config.api_key = '5678'
        _(@env_config.api_key).must_equal '5678'

      end

    end



  end
end
