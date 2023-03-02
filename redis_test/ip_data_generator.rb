require 'faker'

puts Faker::Internet.ip_v4_address

if ARGV[0]
  number_to_generate = ARGV[0].to_i
else
  number_to_generate = 1000
end

output_data = ""

(0..number_to_generate).each do |i|
  output_data += Faker::Internet.ip_v4_address + "\n"
end

File.open("ip_data_#{number_to_generate}.csv", "w") {
  |f| f.write output_data
}

