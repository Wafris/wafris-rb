require 'singleton'

class Configuration

  include Singleton

  attr_accessor :redis_connection, :pool_size, :enabled, :wafris_sha

  def connection_pool
    
    return @wafris_redis_pool if @wafris_redis_pool

    @wafris_redis_pool = ConnectionPool.new(size: pool_size) { redis_connection }

  end

  def pool_size
    @pool_size ||= 20
  end

  def enabled?
    redis_connection
  end

  def script_sha

    return @wafris_sha if @wafris_sha

    wafris_core = File.read(
      File.join(
        File.dirname(__FILE__),
        'wafris_core.lua'
      )
    )
  
    @wafris_sha ||= connection_pool.script(:load, wafris_core)

  end

  def initialize
  
  end

end