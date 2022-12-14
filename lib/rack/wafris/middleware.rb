
module Rack
  module Wafris
    class Middleware

      def configuration
        Configuration.instance
      end

      def initialize(app)
        @app = app
      end

      def call(env)
          request = Rack::Request.new(env)

          if configuration.enabled? 
            
              configuration.connection_pool.with do |conn|
                  time = Time.now
                  status = conn.evalsha(
                  configuration.script_sha,
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