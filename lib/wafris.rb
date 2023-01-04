# frozen_string_literal: true

require 'connection_pool'
require 'redis'

require 'wafris/configuration'
require 'wafris/middleware'

module Wafris
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Wafris::Configuration.new
    end
  end
end
