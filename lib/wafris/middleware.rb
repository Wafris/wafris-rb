# frozen_string_literal: true

module Wafris
  class Middleware
    def initialize(app)
      @app = app
      @notifier = ActiveSupport::Notifications if defined?(ActiveSupport::Notifications)
      ProxyFilter.set_filter
    end

    def call(env)
      wafris_request = WafrisRequest.new(
        Rack::Request.new(env),
        env
      )

      treatment = Wafris.evaluate(wafris_request)

      @notifier&.instrument("#{treatment}.wafris", request: wafris_request, treatment: treatment)

      # These values match what the client tests expect (200, 404, 403, 500)
      if treatment == "Allowed" || treatment == "Passed"
        @app.call(env)
      elsif treatment == "Blocked"
        [403, {"content-type" => "text/plain"}, ["Blocked"]]
      else
        [500, {"content-type" => "text/plain"}, ["Error"]]
      end
    rescue => e
      LogSuppressor.puts_log "[Wafris] Detailed Error: #{e.class} - #{e.message}"
      LogSuppressor.puts_log "[Wafris] Backtrace: #{e.backtrace.join("\n")}"
      @app.call(env)
    end
  end
end
