# frozen_string_literal: true

require 'bundler/setup'

require 'minitest/autorun'
require 'minitest/pride'
require 'rack/test'
require 'rails'

require 'rack/attack'

require 'redis'
require 'connection_pool'

module MiniTest
  class Spec
    include Rack::Test::Methods

    before do
    end

    after do
    end

    def app
      Rack::Builder.new do
        # Use Rack::Lint to test that rack-attack is complying with the rack spec
        use Rack::Lint

        run ->(_env) { [200, {}, ['Hello World']] }
      end.to_app
    end

    def self.it_allows_ok_requests
      it 'must allow ok requests' do
        get '/', {}, 'REMOTE_ADDR' => '127.0.0.1'

        _(last_response.status).must_equal 200
        _(last_response.body).must_equal 'Hello World'
      end
    end
  end
end

module Minitest
  class SharedExamples < Module
    include Minitest::Spec::DSL
  end
end
