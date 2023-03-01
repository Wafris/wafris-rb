local LAST_REQUESTS_TIME = 'last_requests_time'
local TWENTY_FOUR_HOURS = 86400

local ip = ARGV[1]
local ip_to_decimal = ARGV[2]
local unix_time = ARGV[3]
local expire_time = unix_time - TWENTY_FOUR_HOURS
local ip_request_string = "ip-requests-" .. ip
local hour_bucket = ARGV[4]
local user_agent_id = ARGV[5]
local path_id = ARGV[6]
local host_id = ARGV[7]

-- LEADERBOARD DATA COLLECTION
-- Add IP to last_requests_time key by integer timestamp
-- ZADD last_requets_time 1661356145 '192.168.1.1'
redis.call('ZADD', LAST_REQUESTS_TIME, unix_time, ip)
-- Remove IP from last_requests_time if it has been there for 24 hours
-- ZREMRANGEBYSCORE last_requests_time 0 (1661356145 - 86400)
redis.call('ZREMRANGEBYSCORE', LAST_REQUESTS_TIME, 0, expire_time)
-- Add IP to ip-requests-<ip> for leaderboard tracking
-- LPUSH ip-requests-192.168.1.1 1661356145
redis.call('LPUSH', ip_request_string, unix_time)
-- Have the key expire in 24 hours
-- EXPIRE ip-requests-192.168.1.1 86400
redis.call('EXPIRE', ip_request_string, TWENTY_FOUR_HOURS)

-- USER AGENT DATA COLLECTION
-- Increment counter for user agent
-- INC "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
if (user_agent_id ~= nil) then
  redis.call('INCR', user_agent_id)
end

-- GRAPH DATA COLLECTION
-- Increment counter for hourly buckets
-- INC all-ips:2022-10-01:12
redis.call('INCR', hour_bucket)
-- EXPIRE all-ips:2022-10-01:12 86400
redis.call('EXPIRE', hour_bucket, TWENTY_FOUR_HOURS)

-- BLOCKING LOGIC
-- Safelist Range Check
if next(redis.call('ZRANGEBYSCORE', 'allowed_ranges', ip_to_decimal, "+inf", "LIMIT", 0, 1)) then
  return 'Allowed'
-- Blocklist Range Check
elseif next(redis.call('ZRANGEBYSCORE', 'blocked_ranges', ip_to_decimal, "+inf", "LIMIT", 0, 1)) then
  return 'Blocked'
-- No Matches
else
  return 'Not found'
end
