# frozen_string_literal: true

module Wafris
  class Middleware
    def initialize(app)
      @app = app
      ProxyFilter.set_filter
    end

    def call(env)
      request = Rack::Request.new(env)

      treatment = Wafris.evaluate(
        WafrisRequest.new(request, env)
      )

      # These values match what the client tests expect (200, 404, 403, 500)
      if treatment == 'Allowed' || treatment == 'Passed'
        @app.call(env)
      elsif treatment == 'Blocked'
        [403, { 'content-type' => 'text/plain' }, ['Blocked']]
      else
        #ap request
        [500, { 'content-type' => 'text/plain' }, ['Error']]
      end

    rescue StandardError => e
      LogSuppressor.puts_log "[Wafris] Detailed Error: #{e.class} - #{e.message}"
      LogSuppressor.puts_log "[Wafris] Backtrace: #{e.backtrace.join("\n")}"
      @app.call(env)
    end
  end
end
