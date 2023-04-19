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

  describe '.ips_with_num_requests' do
    it 'returns an array of IPs and the number of requests' do
      get '/'

      ips = Wafris.ips_with_num_requests

      # get back [['192.1.1.1.', 1]]
      _(ips.first.size).must_equal 2
    end
  end
end
