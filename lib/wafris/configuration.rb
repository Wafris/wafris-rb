# frozen_string_literal: true

require_relative 'version'

module Wafris
  class Configuration
    attr_accessor :redis
    attr_accessor :redis_pool_size
    attr_accessor :maxmemory
    attr_accessor :quiet_mode
    attr_accessor :logger

    def initialize
      @redis_pool_size = 20
      @maxmemory = 25
      @quiet_mode = false
      @logger = nil
    end

    def connection_pool
      @connection_pool ||=
        ConnectionPool.new(size: redis_pool_size) { redis }
    end

    def logger
      @logger ||= Logger.new(quiet_mode)
    end

    def create_settings
      redis.hset('waf-settings',
                 'version', Wafris::VERSION,
                 'client', 'ruby',
                 'maxmemory', @maxmemory)

      logger.info "[Wafris] firewall enabled. Connected to Redis on #{redis.connection[:host]}. Ready to process requests. Set rules at: https://wafris.org/hub"
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
