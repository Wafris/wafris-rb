# frozen_string_literal: true

require 'rack'
require 'rack/wafris/configuration'

module Rack
  module Wafris
    # Core logic for request block/allow determination
    class Wafris
      class << self
        # For configuration
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        request = Rack::Request.new(env)

        if WAFRIS_REDIS_POOL

          WAFRIS_REDIS_POOL.with do |conn|
            time = Time.now
            status = conn.evalsha(
              WAFRIS_SHA,
              argv: [
                request.ip,
                IPAddr.new(request.ip).to_i,
                time.to_i,
                "all-ips:#{time.strftime('%Y-%m-%d')}:#{time.hour}"
              ]
            )

            if status.eql? 'Blocked'
              puts 'blocked'
              [403, {}, ['Blocked']]
            else
              @app.call(env)
            end
          end
        else
          @app.call(env)
        end
      end
    end
  end
end
