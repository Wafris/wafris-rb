# frozen_string_literal: true

require 'singleton'

module Wafris
  class Configuration
    include Singleton

    attr_accessor :redis_connection, :redis_pool_size, :wafris_sha

    def connection_pool
      return @wafris_redis_pool if @wafris_redis_pool

      @wafris_redis_pool = ConnectionPool.new(size: pool_size) { redis_connection }
    end

    def pool_size
      @pool_size ||= 20
    end

    # todo: figure out how to put a log message out if not enabled
    def enabled?
      !redis_connection.nil?
    end

    def script_sha
      @script_sha ||= connection_pool.script(:load, wafris_core)
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
      Configuration.instance.redis_connection = nil
      Configuration.instance.redis_pool_size = 20
    end
  end
end
