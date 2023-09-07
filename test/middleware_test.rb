# frozen_string_literal: true

require 'test_helper'

module Wafris
  describe Middleware do
    it "should allow ok requests" do
      Wafris.reset

      get '/'

      _(last_response.status).must_equal 200
    end

    it "should rescue from a standard error with a message" do
      Wafris.reset

      Wafris.configure do |config|
        config.redis = Redis.new(url: 'redis://foobar')
      end

      get '/'

      _(last_response.status).must_equal 200
    end
  end
end
