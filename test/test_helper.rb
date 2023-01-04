# frozen_string_literal: true

require "wafris"

require "minitest/autorun"
require 'rack'
require 'rack/test'

class MiniTest::Spec
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      use Wafris::Middleware
      run lambda { |_env| [200, {}, ['Hello World']] }
    end
  end
end
