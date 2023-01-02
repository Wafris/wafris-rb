# frozen_string_literal: true

require 'singleton'

module Wafris
  class Configuration
    include Singleton

    attr_accessor :redis_connection, :redis_pool_size

    def initialize
      reset
    end

    def connection_pool
      @connection_pool ||=
        ConnectionPool.new(size: redis_pool_size) { redis_connection }
    end

    # todo: figure out how to put a log message out if not enabled
    def enabled?
      !redis_connection.nil?
    end

    def script_sha
      @script_sha ||= redis_connection.script(:load, wafris_core)
    end

    def wafris_core
      File.read(
        File.join(
          File.dirname(__FILE__),
          'wafris_core.lua'
        )
      )
    end

    def reset
      @redis_connection = nil
      @redis_pool_size = 20
    end
  end
end
