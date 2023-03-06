

-- Template strings below are replaced with generated 
-- data from the ip_data_generator.rb script

local ipArray = {IP_LIST}
local timestampArray = {TIMESTAMP_LIST}


-- For in script debugging of values
local logtable = {}
 
local function logit(msg)
  logtable[#logtable+1] = msg
end

-- For generating and manipulating timebuckets
local function get_timebucket_from_timestamp(unix_time)
  local day_count, year, days, month = function(yr) return (yr % 4 == 0 and (yr % 100 ~= 0 or yr % 400 == 0)) and 366 or 365 end, 1970, math.ceil(unix_time/86400)

  while days >= day_count(year) do
      days = days - day_count(year) year = year + 1
  end
  local tab_overflow = function(seed, table) for i = 1, #table do if seed - table[i] <= 0 then return i, seed end seed = seed - table[i] end end
  month, days = tab_overflow(days, {31,(day_count(year) == 366 and 29 or 28),31,30,31,30,31,31,30,31,30,31})
  local hours, minutes, seconds = math.floor(unix_time / 3600 % 24), math.floor(unix_time / 60 % 60), math.floor(unix_time % 60)
  local period = hours > 12 and "pm" or "am"
  -- hours = hours > 12 and hours - 12 or hours == 0 and 12 or hours
  return string.format("%04d-%02d-%02d-%02d", year, month, days, hours, minutes, seconds, period)
end


-- Redis test setup - delete all existing DB
redis.call('flushdb')

-- Interior of this for loop is what should go into wafris_core.lua
for i = 1, #(ipArray) do

  -- Configuration
  local max_requests = 100000
  local max_requests_per_ip = 10000

  -- Setup
  local ip = ipArray[i]
  local timestamp = timestampArray[i]

  -- STREAMS
  -- For: Relationship of IP to time of Request (Stream)
  -- TODO: in production must replace timestamp with '*'
  local request_id = redis.call('XADD', 'ip-requests-stream', 'MAXLEN', '~', max_requests, timestamp, 'ip', ip )

  -- For: Looking up Requests an IP has made (Stream) / time of request
  local ip_stream_key = "ip-stream:" .. ip
  local ip_stream_id = redis.call('XADD', ip_stream_key, 'MAXLEN', '~', max_requests_per_ip, '*', 'request_id', request_id)

  -- TIMEBUCKETS
  -- TODO: no customization of timebuckets is implemented so it's hardcoded to hours
  local current_timebucket = get_timebucket_from_timestamp(timestamp)

  -- For: Precalc of Number of Requests (Key)
  local requests_count_key = "requests-count:" .. current_timebucket
  redis.call('INCR', requests_count_key)

  -- For: Precalc of Number of Requests from an IP (Key)
  local ips_count_bucket_key = "ips-count:" .. ip .. ":" .. current_timebucket
  redis.call('INCR', ips_count_bucket_key)

  -- For: Precalc of Number of Unique IPs making Requests (HLL)
  local ips_count_hll_key = "unique-ips:" .. current_timebucket
  redis.call('PFADD', ips_count_hll_key, ip)

  -- For: Leaderboard of IPs with Request count as score
  local ip_leaderboard_sset_key = "ip-leader-sset:" .. current_timebucket
  redis.call('ZINCRBY', ip_leaderboard_sset_key, 1, ip)

  logit(ip_stream_key)

end






-- Only for testing script
return logtable