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
local function increment_timebucket_for(type, timebucket, property)
  -- TODO: breaking change will to switch to client_ip: prefix
  type = type or "ip-"
  redis.call("ZINCRBY", type .. "leader-sset:" .. timebucket, 1, property)
end

-- Configuration
local max_requests = 100000
local max_requests_per_ip = 10000

local client_ip = ARGV[1]
local client_ip_to_decimal = ARGV[2]
local unix_time_milliseconds = ARGV[3]
local unix_time = ARGV[3] / 1000
local user_agent = ARGV[4]
local request_path = ARGV[5]
local host = ARGV[6]

-- Initialize local variables
local request_id = get_request_id(nil, client_ip, max_requests)
local current_timebucket = get_time_bucket_from_timestamp(unix_time_milliseconds)

-- GRAPH DATA COLLECTION
add_to_HLL_request_count(current_timebucket, request_id)

-- LEADERBOARD DATA COLLECTION
-- TODO: breaking change will to switch to client_ip: prefix
increment_timebucket_for(nil, current_timebucket, client_ip)
increment_timebucket_for("user_agent:", current_timebucket, user_agent)
increment_timebucket_for("request_path:", current_timebucket, request_path)
increment_timebucket_for("host:", current_timebucket, host)

redis.call("ZRANGEBYSCORE", "blocked_ranges", client_ip_to_decimal, client_ip_to_decimal, "LIMIT", 0, 1)

-- BLOCKING LOGIC
-- TODO: ZRANGEBYSCORE is deprecated in Redis 6.2+. Replace with ZRANGE
if
  -- ZRANGEBYSCORE will always return a lua table, even if empty
  -- TODO: When we introduce ranges we'll have to do an exact check followed by a range starting with decimal ip to infinity.
  -- If the first result returned is "END" that means it falls in the range
  next(redis.call("ZRANGEBYSCORE", "blocked_ranges", client_ip_to_decimal, client_ip_to_decimal, "LIMIT", 0, 1)) ~= nil
then
  increment_timebucket_for("wafris:blocked:", current_timebucket, client_ip)
  return "Blocked"
-- No Matches
else
  return "Allowed"
end
