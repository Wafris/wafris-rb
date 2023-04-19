# frozen_string_literal: true

module Wafris
  class Configuration
    attr_accessor :redis
    attr_accessor :redis_pool_size

    def initialize
      @redis = Redis.new
      @redis_pool_size = 20
    end

    def connection_pool
      @connection_pool ||=
        ConnectionPool.new(size: redis_pool_size) { redis }
    end

    def enabled?
      redis.ping

      return true
    rescue Redis::CannotConnectError
      raise <<~CONNECTION_ERROR
        Wafris cannot connect to Redis.

        The current Redis instance points to a connection that
        cannot be pinged.
      CONNECTION_ERROR
    end

    def core_sha
      @core_sha ||= redis.script(:load, wafris_core)
    end

    def wafris_core
      read_lua_dist("wafris_core")
    end

    def graph_sha
      @graph_sha ||= redis.script(:load, wafris_graph)
    end

    def wafris_graph
      read_lua_dist("get_graph_data")
    end

    private

    def read_lua_dist(filename)
      File.read(
        File.join(
          File.dirname(__FILE__),
          "../lua/dist/#{filename}.lua"
        )
      )
    end
  end
end
