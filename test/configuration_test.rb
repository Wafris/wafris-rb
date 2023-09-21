# frozen_string_literal: true

require 'test_helper'

module Wafris
  describe Configuration do
    before do
      @config = Configuration.new
    end

    describe "#initialize" do
      it "allows setting attributes with a block" do
        @config.redis = "some_redis_value"
        @config.redis_pool_size = 30

        _(@config.redis).must_equal "some_redis_value"
        _(@config.redis_pool_size).must_equal 30
      end
    end

    describe "#connection_pool" do
      it "uses the set pool size" do
        @config.redis_pool_size = 10

        _(@config.connection_pool.size).must_equal 10
      end

      it "should default connection pool size" do
        _(@config.connection_pool.size).must_equal 20
      end
    end

    describe "#create_settings" do
      # This test assumes that a Redis server is running and accessible.
      it "sets the waf settings in Redis" do
        redis_mock = Minitest::Mock.new
        redis_mock.expect(:hset, true, ['waf-settings', 'version', Wafris::VERSION, 'client', 'ruby'])

        @config.redis = redis_mock
        @config.create_settings

        redis_mock.verify
      end
    end
  end
end
