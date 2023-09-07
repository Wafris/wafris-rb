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
  end
end
