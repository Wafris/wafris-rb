# frozen_string_literal: true

require 'rack'
require 'redis'
require 'connection_pool'
require 'rack/wafris/configuration'
require 'rack/wafris/middleware'

module Rack
  module Wafris
    # Core logic for request block/allow determination
    
    class << self

        def configuration
          yield Configuration.instance
        end
    
    end
  
    def configuration
      Configuration.instance
    end

  end
end
