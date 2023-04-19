function get_time_bucket_from_timestamp(unix_time_milliseconds)
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

function get_time_buckets(unix_time_milliseconds)
  local time_buckets = {}

  for i = 23, 0, -1 do
    table.insert(time_buckets, get_time_bucket_from_timestamp(unix_time_milliseconds - (1000 * 60 * 60 * i)))
  end
  return time_buckets
end
