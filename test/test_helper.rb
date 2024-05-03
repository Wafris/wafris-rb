# frozen_string_literal: true

require "wafris"

require "minitest/autorun"
require 'rack'
require 'rack/test'
require 'webmock'
require 'webmock/minitest'
require 'fakefs/safe'

class Minitest::Spec
  include Rack::Test::Methods

  def reset_environment_variables
    env_vars = [
      'WAFRIS_API_KEY',
      'WAFRIS_DB_FILE_PATH',
      'WAFRIS_DB_FILE_NAME',
      'WAFRIS_DOWNSYNC_CUSTOM_RULES_INTERVAL',
      'WAFRIS_DOWNSYNC_DATA_SUBSCRIPTIONS_INTERVAL',
      'WAFRIS_DOWNSYNC_URL',
      'WAFRIS_UPSYNC_URL',
      'WAFRIS_UPSYNC_INTERVAL',
      'WAFRIS_UPSYNC_QUEUE_LIMIT'
    ]

    env_vars.each do |var|
      ENV[var] = nil
    end
  end

  def app
    Rack::Builder.new do
      use Wafris::Middleware
      run lambda { |_env| [200, {}, ['Hello World']] }
    end
  end
end
