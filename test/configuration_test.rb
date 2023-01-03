# frozen_string_literal: true

require 'test_helper'

module Wafris
  describe Configuration do
    before do
      @configuration = Configuration.new
    end

    it "should default connection pool size" do
      _(@configuration.connection_pool.size).must_equal 20
    end

    it "should not be enabled if given an invalid Redis connection" do
      @configuration.redis = Redis.new(url: 'redis://foobar')
      _ { @configuration.enabled? }.must_raise RuntimeError
    end

    it "should be enabled if given a valid Redis connection" do
      @configuration.redis = Redis.new(url: 'redis://127.0.0.1:6379/0')
      _(@configuration.enabled?).must_equal true
    end
  end
end
