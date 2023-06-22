# frozen_string_literal: true

module Wafris
  class Configuration
    attr_accessor :redis
    attr_accessor :redis_pool_size

    def initialize
      @redis = Redis.new(
        url: ENV['REDIS_URL'],
        ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
      )
      @redis_pool_size = 20

      set_version if ENV['REDIS_URL']
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

    def set_version
      version_line = File.open(
        file_path("wafris_core"),
        &:readline
      )
      version = version_line.slice(/v\d.\d/)
      redis.set('version', version)
    end

    def core_sha
      @core_sha ||= redis.script(:load, wafris_core)
    end

    def wafris_core
      read_lua_dist("wafris_core")
    end

    private

    def read_lua_dist(filename)
      File.read(
        file_path(filename)
      )
    end

    def file_path(filename)
      File.join(
        File.dirname(__FILE__),
        "../lua/dist/#{filename}.lua"
      )
    end
  end
end
