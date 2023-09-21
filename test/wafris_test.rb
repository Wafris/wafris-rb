# frozen_string_literal: true

require 'test_helper'

describe Wafris do
  describe '.configure' do
    it 'creates a connection pool with a 60 size' do
      Wafris.configure do |config|
        config.redis = Redis.new
        config.redis_pool_size = 60
      end

      _(Wafris.configuration.connection_pool.size).must_equal 60
    end
  end
end
