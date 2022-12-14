# frozen_string_literal: true

require "wafris_ruby"

Wafris.configuration do |c|
  puts "configuration"
  c.redis_connection = Redis.new(url: ENV['REDIS_URL'])
  c.redis_pool_size = 60
end

Wafris.allow_request
