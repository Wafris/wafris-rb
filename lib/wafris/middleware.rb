# frozen_string_literal: true

module Wafris
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      if Wafris.configuration.enabled? && Wafris.allow_request?(request)
        @app.call(env)
      else
        puts 'blocked'
        [403, {}, ['Blocked']]
      end
    end
  end
end
