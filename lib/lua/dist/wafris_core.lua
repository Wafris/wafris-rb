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

-- For: Leaderboard of IPs with Request count as score
local function increment_timebucket_for_ip(timebucket, ip)
  redis.call("ZINCRBY", "ip-leader-sset:" .. timebucket, 1, ip)
end

-- Configuration
local max_requests = 100000
local max_requests_per_ip = 10000
local LAST_REQUESTS_TIME = "last_requests_time"
local TWENTY_FOUR_HOURS = 86400

local ip = ARGV[1]
local ip_to_decimal = ARGV[2]
local unix_time_milliseconds = ARGV[3]
local unix_time = ARGV[3] / 1000
local expire_time = unix_time - TWENTY_FOUR_HOURS
local ip_request_string = "ip-requests-" .. ip

-- Initialize local variables
local request_id = get_request_id(nil, ip, max_requests)
local current_timebucket = get_time_bucket_from_timestamp(unix_time_milliseconds)

-- GRAPH DATA COLLECTION
add_to_HLL_request_count(current_timebucket, request_id)

-- LEADERBOARD DATA COLLECTION
-- Add IP to last_requests_time key by integer timestamp
-- ZADD last_requets_time 1661356145 '192.168.1.1'
redis.call("ZADD", LAST_REQUESTS_TIME, unix_time, ip)
-- Remove IP from last_requests_time if it has been there for 24 hours
-- ZREMRANGEBYSCORE last_requests_time 0 (1661356145 - 86400)
redis.call("ZREMRANGEBYSCORE", LAST_REQUESTS_TIME, 0, expire_time)
-- Add IP to ip-requests-<ip> for leaderboard tracking
-- LPUSH ip-requests-192.168.1.1 1661356145
redis.call("LPUSH", ip_request_string, unix_time)
-- Have the key expire in 24 hours
-- EXPIRE ip-requests-192.168.1.1 86400
redis.call("EXPIRE", ip_request_string, TWENTY_FOUR_HOURS)
-- For: Leaderboard of IPs with Request count as score
local ip_leaderboard_sset_key = "ip-leader-sset:" .. current_timebucket
redis.call("ZINCRBY", ip_leaderboard_sset_key, 1, ip)
increment_timebucket_for_ip(current_timebucket, ip)

-- BLOCKING LOGIC
-- Safelist Range Check
if next(redis.call("ZRANGEBYSCORE", "allowed_ranges", ip_to_decimal, "+inf", "LIMIT", 0, 1)) then
  return "Allowed"
-- Blocklist Range Check
elseif next(redis.call("ZRANGEBYSCORE", "blocked_ranges", ip_to_decimal, "+inf", "LIMIT", 0, 1)) then
  return "Blocked"
-- No Matches
else
  return "Not found"
end
