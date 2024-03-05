

local USE_TIMESTAMPS_AS_REQUEST_IDS = false
local EXPIRATION_IN_SECONDS = tonumber(redis.call("HGET", "waf-settings", "expiration-time")) or 86400
local EXPIRATION_OFFSET_IN_SECONDS = 3600


local function get_timebucket(timestamp_in_seconds)
  local startOfHourTimestamp = math.floor(timestamp_in_seconds / 3600) * 3600
  return tostring(startOfHourTimestamp)
end

local function set_property_value_id_lookups(property_abbreviation, property_value)

  local value_key = property_abbreviation .. "V" .. property_value
  local property_id = redis.call("GET", value_key)

  if property_id == false then
    property_id = redis.call("INCR", property_abbreviation .. "-id-counter")
    redis.call("SET", value_key, property_id)
    redis.call("SET", property_abbreviation .. "I" .. property_id, property_value)
  end

  redis.call("EXPIRE", value_key, EXPIRATION_IN_SECONDS + EXPIRATION_OFFSET_IN_SECONDS)
  redis.call("EXPIRE", property_abbreviation .. "I" .. property_id, EXPIRATION_IN_SECONDS + EXPIRATION_OFFSET_IN_SECONDS)

  return property_id
end

local function increment_leaderboard_for(property_abbreviation, property_id, timebucket)

  local key = property_abbreviation .. "L" .. timebucket
  redis.call("ZINCRBY", key, 1, property_id)
  redis.call("EXPIRE", key, EXPIRATION_IN_SECONDS)
end

local function set_property_to_requests_list(property_abbreviation, property_id, request_id, timebucket)

  local key = property_abbreviation .. "R" .. property_id .. "-" .. timebucket
  redis.call("LPUSH", key, request_id)

  redis.call("EXPIRE", key, EXPIRATION_IN_SECONDS + EXPIRATION_OFFSET_IN_SECONDS)
end


local function ip_in_hash(hash_name, ip_address)
  local found_ip = redis.call('HEXISTS', hash_name, ip_address)

  if found_ip == 1 then
    return ip_address
  else
    return false
  end
end

local function ip_in_cidr_range(cidr_set, ip_decimal_lexical)

  local higher_value = redis.call('ZRANGEBYLEX', cidr_set, '['..ip_decimal_lexical, '+', 'LIMIT', 0, 1)[1]

  local lower_value = redis.call('ZREVRANGEBYLEX', cidr_set, '['..ip_decimal_lexical, '-', 'LIMIT', 0, 1)[1]

  if not (higher_value and lower_value) then
      return false
  end

  local higher_compare = higher_value:match('([^%-]+)$')
  local lower_compare = lower_value:match('([^%-]+)$')

  if higher_compare == lower_compare then
      return lower_compare
  else
      return false
  end
end

local function escapePattern(s)
    local patternSpecials = "[%^%$%(%)%%%.%[%]%*%+%-%?]"
    return s:gsub(patternSpecials, "%%%1")
end

local function match_by_pattern(property_abbreviation, property_value)
  local hash_name = "rules-blocked-" .. property_abbreviation

  local patterns = redis.call('HKEYS', hash_name)

  for _, pattern in ipairs(patterns) do
    if string.find(string.lower(property_value), string.lower(escapePattern(pattern))) then
      return pattern
    end
  end

  return false
end

local function blocked_by_rate_limit(request_properties)

  local rate_limiting_rules_values = redis.call('HKEYS', 'rules-blocked-rate-limits')

  for i, rule_name in ipairs(rate_limiting_rules_values) do

    local conditions_hash = redis.call('HGETALL', rule_name .. "-conditions")

    local all_conditions_match = true

    for j = 1, #conditions_hash, 2 do
      local condition_key = conditions_hash[j]
      local condition_value = conditions_hash[j + 1]

      if request_properties[condition_key] ~= condition_value then
        all_conditions_match = false
        break
      end
    end

    if all_conditions_match then

      local rule_settings_key = rule_name .. "-settings"

      local limit, time_period, limited_by, rule_id = unpack(redis.call('HMGET', rule_settings_key, 'limit', 'time-period', 'limited-by', 'rule-id'))

      local throttle_key = rule_name .. ":" .. limit .. "V" .. request_properties.ip

      local new_value = redis.call('INCR', throttle_key)

      if new_value == 1 then
        redis.call('EXPIRE', throttle_key, tonumber(time_period))
      end

      if tonumber(new_value) >= tonumber(limit) then
        return rule_id
      else
        return false
      end
    end
  end
end

local function check_rules(functions_to_check)
  for _, check in ipairs(functions_to_check) do

    local rule = check.func(unpack(check.args))
    local category = check.category

    if type(rule) == "string" then
      return rule, category
    end
  end

  return false, false
end

local function check_blocks(request)
  local rule_categories = {
    { category = "bi", func = ip_in_hash, args = { "rules-blocked-i", request.ip } },
    { category = "bc", func = ip_in_cidr_range, args = { "rules-blocked-cidrs-set", request.ip_decimal_lexical } },
    { category = "bs", func = ip_in_cidr_range, args = { "rules-blocked-cidrs-subscriptions-set", request.ip_decimal_lexical } },    
    { category = "bu", func = match_by_pattern, args = { "u", request.user_agent } },
    { category = "bp", func = match_by_pattern, args = { "p", request.path } },
    { category = "ba", func = match_by_pattern, args = { "a", request.parameters } },
    { category = "bh", func = match_by_pattern, args = { "h", request.host } },
    { category = "bm", func = match_by_pattern, args = { "m", request.method } },
    { category = "bd", func = match_by_pattern, args = { "rh", request.headers } },
    { category = "bpb", func = match_by_pattern, args = { "pb", request.post_body } },
    { category = "brl", func = blocked_by_rate_limit, args = { request } }
  }

  return check_rules(rule_categories)
end

local function check_allowed(request)
  local rule_categories = {
    { category = "ai", func = ip_in_hash, args = { "rules-allowed-i", request.ip } },
    { category = "ac", func = ip_in_cidr_range, args = { "rules-allowed-cidrs-set", request.ip_decimal_lexical } }
  }

  return check_rules(rule_categories)
end

local request = {
  ["ip"] = ARGV[1],
  ["ip_decimal_lexical"] = string.rep("0", 39 - #ARGV[2]) .. ARGV[2],
  ["ts_in_milliseconds"] = ARGV[3],
  ["ts_in_seconds"] = ARGV[3] / 1000,
  ["user_agent"] = ARGV[4],
  ["path"] = ARGV[5],
  ["parameters"] = ARGV[6],
  ["host"] = ARGV[7],
  ["method"] = ARGV[8],
  ["headers"] = ARGV[9],
  ["post_body"] = ARGV[10],
  ["ip_id"] = set_property_value_id_lookups("i", ARGV[1]),
  ["user_agent_id"] = set_property_value_id_lookups("u", ARGV[4]),
  ["path_id"] = set_property_value_id_lookups("p", ARGV[5]),
  ["parameters_id"] = set_property_value_id_lookups("a", ARGV[6]),
  ["host_id"] = set_property_value_id_lookups("h", ARGV[7]),
  ["method_id"] = set_property_value_id_lookups("m", ARGV[8])
}



local current_timebucket = get_timebucket(request.ts_in_seconds)

  local blocked_rule = false
  local blocked_category = nil
  local treatment = "p"

  local stream_id

  if USE_TIMESTAMPS_AS_REQUEST_IDS == true then
      stream_id = request.ts_in_milliseconds
  else
      stream_id = "*"
  end

  local stream_args = {
    "XADD",
    "rStream",
    "MINID",
    tostring((current_timebucket - EXPIRATION_IN_SECONDS) * 1000 ),
    stream_id,
    "i", request.ip_id,
    "u", request.user_agent_id,
    "p", request.path_id,
    "h", request.host_id,
    "m", request.method_id,
    "a", request.parameters_id,
  }

  local allowed_rule, allowed_category = check_allowed(request)

  if allowed_rule then
    table.insert(stream_args, "t")
    table.insert(stream_args, "a")

    treatment = "a"

    table.insert(stream_args, "ac")
    table.insert(stream_args, allowed_category)

    table.insert(stream_args, "ar")
    table.insert(stream_args, allowed_rule)

  else
    blocked_rule, blocked_category = check_blocks(request)
  end

  if blocked_rule then
    table.insert(stream_args, "t")
    table.insert(stream_args, "b")

    treatment = "b"

    table.insert(stream_args, "bc")
    table.insert(stream_args, blocked_category)

    table.insert(stream_args, "br")
    table.insert(stream_args, blocked_rule)
  end

  if blocked_rule == false and allowed_rule == false then
    table.insert(stream_args, "t")
    table.insert(stream_args, "p")
  end

  local request_id = redis.call(unpack(stream_args))

  increment_leaderboard_for("i", request.ip_id, current_timebucket)
  increment_leaderboard_for("u", request.user_agent_id, current_timebucket)
  increment_leaderboard_for("p", request.path_id, current_timebucket)
  increment_leaderboard_for("a", request.parameters_id, current_timebucket)
  increment_leaderboard_for("h", request.host_id, current_timebucket)
  increment_leaderboard_for("m", request.method_id, current_timebucket)
  increment_leaderboard_for("t", treatment, current_timebucket)

  set_property_to_requests_list("i", request.ip_id, request_id, current_timebucket)
  set_property_to_requests_list("u", request.user_agent_id, request_id, current_timebucket)
  set_property_to_requests_list("p", request.path_id, request_id, current_timebucket)
  set_property_to_requests_list("a", request.parameters_id, request_id, current_timebucket)
  set_property_to_requests_list("h", request.host_id, request_id, current_timebucket)
  set_property_to_requests_list("m", request.method_id, request_id, current_timebucket)
  set_property_to_requests_list("t", treatment, request_id, current_timebucket)

  if blocked_rule ~= false then
    increment_leaderboard_for("bc", blocked_category, current_timebucket)
    set_property_to_requests_list("bc", blocked_category, request_id, current_timebucket)

    increment_leaderboard_for("br", blocked_rule, current_timebucket)
    set_property_to_requests_list("br", blocked_rule, request_id, current_timebucket)
  end

  if allowed_rule ~= false then
    increment_leaderboard_for("ac", allowed_category, current_timebucket)
    set_property_to_requests_list("ac", allowed_category, request_id, current_timebucket)

    increment_leaderboard_for("ar", allowed_rule, current_timebucket)
    set_property_to_requests_list("ar", allowed_rule, request_id, current_timebucket)
  end

if blocked_rule ~= false then
  return "Blocked"
elseif allowed_rule ~= false then
  return "Allowed"
else
  return "Passed"
end
