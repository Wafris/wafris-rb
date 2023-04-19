-- Compiled from:
-- src/get_time_buckets.lua

-- Code was pulled from https://otland.net/threads/how-convert-timestamp-to-date-type.251657/
-- An alternate solution is https://gist.github.com/markuman/e96d04139cd8acc33604
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

local function get_time_buckets(unix_time_milliseconds)
  local time_buckets = {}

  for i = 23, 0, -1 do
    table.insert(time_buckets, get_time_bucket_from_timestamp(unix_time_milliseconds - (1000 * 60 * 60 * i)))
  end
  return time_buckets
end

local function num_requests(time_bucket)
  local request_keys = redis.call("KEYS", "unique-requests:" .. time_bucket)
  redis.call("PFMERGE", "merged_unique-requests", unpack(request_keys))
  return redis.call("PFCOUNT", "merged_unique-requests")
end

local graph_data = {}
local unix_time_milliseconds = ARGV[1]
local time_buckets = get_time_buckets(unix_time_milliseconds)
-- use the get_time_buckets method to get each time bucket and
-- the associated count for that bucket
for bucket in pairs(time_buckets) do
  table.insert(graph_data, time_buckets[bucket])
  table.insert(graph_data, num_requests(time_buckets[bucket]))
end

return graph_data
