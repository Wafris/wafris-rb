
module Rack
  module Wafris
    class Middleware


      def initialize(app)
        @app = app
      end

      def call(env)
          request = Rack::Request.new(env)

          if Wafris.enabled? 
            
                  if Wafris.approved(parameters).eql? 'Blocked'
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