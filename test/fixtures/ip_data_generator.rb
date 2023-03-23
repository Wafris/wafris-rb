# frozen_string_literal: true

require 'faker'
require 'ipaddr'
require 'debug'

# Generates a timestamp in the last 24 hours of elapsed time
end_time = (Time.now.to_f * 1000).to_i
start_time = (end_time - (24*60*60*1000)).to_i

if ARGV[0]
  number_to_generate = ARGV[0].to_i
else
  number_to_generate = 10
end

ip_list = []

(1..number_to_generate).each do |i|
  ip_list << IPAddr.new(Faker::Internet.ip_v4_address).to_i
end

# Unique list of timestamps in ascending order
timestamp_list = (start_time..end_time).to_a.shuffle.take(number_to_generate).sort

puts "#{timestamp_list.size} timestamps generated"
puts "#{ip_list.size} IP addresses generated"

lua_loader_file = File.open("data_load.lua").read
lua_loader_file.gsub!("IP_LIST", ip_list.join(","))

# Note: timestamps need to be passed in in ascending order or else the stream adding
# fails as IDs must be sequentially larger
lua_loader_file.gsub!("TIMESTAMP_LIST", timestamp_list.sort.join(","))

File.write("#{ARGV[0]}_data_load.lua", lua_loader_file)

return "done"

# Multiple test cases
# 1. 5 IPs with 5 timestamps each
# 2. 5 IPs with overlapping timestamps
#    If the IPs overlap use the Redis unix timestamp
