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

return get_timebucket_from_timestamp('1678039768')