require_relative 'lib/wafris-ruby'

Wafris.configuration do |c|
  puts "configuration"
  c.redis_connection = Redis.new(ENV['REDIS_URL'])
  c.redis_pool_size = 60
end

Wafris.allow_request()