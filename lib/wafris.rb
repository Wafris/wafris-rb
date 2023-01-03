# frozen_string_literal: true

require 'wafris/configuration'
require 'redis'
require 'connection_pool'

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
