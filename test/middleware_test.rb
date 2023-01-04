# frozen_string_literal: true

require 'test_helper'

module Wafris
  describe Middleware do
    it "should allow ok requests" do
      get '/'

      _(last_response.status).must_equal 200
    end
  end
end
