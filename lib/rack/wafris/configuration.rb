# frozen_string_literal: true

if ENV['WAFRIS_REDIS_URL'] || ENV['REDIS_URL']

  redis_connection_url = ENV['WAFRIS_REDIS_URL'] || ENV['REDIS_URL']

  WAFRIS_REDIS = Redis.new(
    url: redis_connection_url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  )

  WAFRIS_REDIS_POOL = ConnectionPool.new(size: 60) { REDIS }

  wafris_core = File.read(
    File.join(
      File.dirname(__FILE__),
      'rack/wafris/wafris_core.lua'
    )
  )

  WAFRIS_SHA ||= REDIS.script(:load, wafris_core)

  puts 'WAFRIS: Client Initalized'

else
  puts 'WAFRIS: Redis URL not found'
end
