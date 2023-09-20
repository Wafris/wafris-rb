# frozen_string_literal: true

require_relative 'version'

module Wafris
  class Configuration
    attr_accessor :redis
    attr_accessor :redis_pool_size

    private :initialize

      puts "[Wafris] attempting firewall connection via REDIS_URL." unless LogSuppressor.suppress_logs?
      puts "[Wafris] firewall disabled. Cannot connect to REDIS_URL. Will attempt Wafris.configure if it exists." unless LogSuppressor.suppress_logs?
    def initialize_with_block
      yield self
      @redis_pool_size = 20
    end

    def connection_pool
      @connection_pool ||=
        ConnectionPool.new(size: redis_pool_size) { redis }
    end

    def create_settings
      redis.hset('waf-settings',
                 'version', Wafris::VERSION,
                 'client', 'ruby',
                 'redis-host', 'heroku')
      puts "[Wafris] firewall enabled. Connected to Redis. Ready to process requests. Set rules at: https://wafris.org/hub" unless LogSuppressor.suppress_logs?
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
