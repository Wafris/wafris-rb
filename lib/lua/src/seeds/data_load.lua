-- Template strings below are replaced with generated
-- data from the ip_data_generator.rb script
-- local ipArray = { }
-- local timestampArray = { }
-- redis.debug("Timestamp count: ", #timestampArray)

local function get_time_bucket_from_timestamp(unix_time_milliseconds)
  local function calculate_years_number_of_days(yr)
    return (yr % 4 == 0 and (yr % 100 ~= 0 or yr % 400 == 0)) and 366 or 365
  end

  local function get_year_and_day_number(year, days)
    while days >= calculate_years_number_of_days(year) do
      days = days - calculate_years_number_of_days(year)
      year = year + 1
    end
    return year, days
  end

  local function get_month_and_month_day(days, year)
    local days_in_each_month = {
      31,
      (calculate_years_number_of_days(year) == 366 and 29 or 28),
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31,
    }

    for month = 1, #days_in_each_month do
      if days - days_in_each_month[month] <= 0 then
        return month, days
      end
      days = days - days_in_each_month[month]
    end
  end

  local unix_time = unix_time_milliseconds / 1000
  local year = 1970
  local days = math.ceil(unix_time / 86400)
  local month = nil

  year, days = get_year_and_day_number(year, days)
  month, days = get_month_and_month_day(days, year)
  local hours = math.floor(unix_time / 3600 % 24)
  -- local minutes, seconds = math.floor(unix_time / 60 % 60), math.floor(unix_time % 60)
  -- hours = hours > 12 and hours - 12 or hours == 0 and 12 or hours
  return string.format("%04d-%02d-%02d-%02d", year, month, days, hours)
end

-- For: Relationship of IP to time of Request (Stream)
local function get_request_id(timestamp, ip, max_requests)
  timestamp = timestamp or "*"
  local request_id = redis.call("XADD", "ip-requests-stream", "MAXLEN", "~", max_requests, timestamp, "ip", ip)
  return request_id
end

local function add_to_HLL_request_count(timebucket, request_id)
  redis.call("PFADD", "unique-requests:" .. timebucket, request_id)
end

-- Configuration
local max_requests = 100000
local max_requests_per_ip = 10000

-- Interior of this for loop is what should go into wafris_core.lua
for i = 1, #timestampArray do
  -- Setup
  local ip = ipArray[math.random(#ipArray)]
  local timestamp = timestampArray[i]

  local request_id = get_request_id(timestamp, ip, max_requests)

  -- GRAPH DATA COLLECTION
  local current_timebucket = get_time_bucket_from_timestamp(timestamp)
  add_to_HLL_request_count(current_timebucket, request_id)

  -- For: Looking up Requests an IP has made (Stream) / time of request
  local ip_stream_key = "ip-stream:" .. ip
  local ip_stream_id =
    redis.call("XADD", ip_stream_key, "MAXLEN", "~", max_requests_per_ip, "*", "request_id", request_id)

  -- For: Precalc of Number of Requests (Key)
  local requests_count_key = "requests-count:" .. current_timebucket
  redis.call("INCR", requests_count_key)

  -- For: Precalc of Number of Requests from an IP (Key)
  local ips_count_bucket_key = "ips-count:" .. ip .. ":" .. current_timebucket
  redis.call("INCR", ips_count_bucket_key)

  -- For: Precalc of Number of Unique IPs making Requests (HLL)
  local ips_count_hll_key = "unique-ips:" .. current_timebucket
  redis.call("PFADD", ips_count_hll_key, ip)

  -- For: Leaderboard of IPs with Request count as score
  local ip_leaderboard_sset_key = "ip-leader-sset:" .. current_timebucket
  redis.call("ZINCRBY", ip_leaderboard_sset_key, 1, ip)
end
