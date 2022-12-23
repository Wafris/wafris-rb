# frozen_string_literal: true

require 'test_helper'
require 'wafris/configuration'

module Wafris
  describe Configuration do
    before do
      Configuration.instance.reset
      @configuration = Configuration.instance
    end

    it "allows Redis connection configuration via a block" do
      Wafris.configuration do |c|
        c.redis_connection = Redis.new
        c.redis_pool_size = 60
      end

      _(@configuration.redis_pool_size).must_equal 60
      _(@configuration.redis_connection).wont_be_nil
    end

    it "should default connection pool size" do 
      
      _(@configuration.redis_pool_size).must_equal 20
    end

    it "should not be enabled if no Redis connection" do 
      _(@configuration.enabled?).must_equal false
    end

    it "should be enabled if Redis connection exists" do
      Wafris.configuration do |c|
        c.redis_connection = Redis.new
        c.redis_pool_size = 60 
      end

      _(@configuration.enabled?).must_equal true
    end
  end

end
