# frozen_string_literal: true

require 'test_helper'

module Wafris
  describe Middleware do
    it "should pass requests if no API key" do
      get '/'
      _(last_response.status).must_equal 200
    end
  end
end