require_relative 'lib/rack/wafris'

Rack::Wafris.configuration do |c|
  puts "configuration"
  c.redis_connection = Redis.new(ENV['REDIS_URL'])
  c.connection_pool_size = 60
end