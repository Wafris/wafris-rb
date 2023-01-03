# frozen_string_literal: true

require 'test_helper'

describe Wafris do
  describe '#configure' do
    before do
      Wafris.configure do |config|
        config.redis_pool_size = 60
      end
    end

    it 'creates a connection pool with a 60 size' do
      _(Wafris.configuration.connection_pool.size).must_equal 60
    end
  end
end
