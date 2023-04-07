# frozen_string_literal: true

require 'test_helper'

describe Wafris do
  describe '.configure' do
    it 'creates a connection pool with a 60 size' do
      Wafris.reset

      Wafris.configure do |config|
        config.redis_pool_size = 60
      end

      _(Wafris.configuration.connection_pool.size).must_equal 60
    end
  end

  describe '.reset' do
    it 'resets the configuration' do
      Wafris.reset

      _(Wafris.configuration.connection_pool.size).must_equal 20
    end
  end

  describe '.request_buckets(time)' do
    it 'returns an array of 24 time buckets and 24 request counts' do
      now = Time.now
      buckets = Wafris.request_buckets(now)

      _(buckets.size).must_equal 48
    end
  end
end
