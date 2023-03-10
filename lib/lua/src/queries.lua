local function num_requests(start_time, end_time)
  local request_keys = redis.call('KEYS', 'unique-requests:*')
  redis.call('PFMERGE', 'merged_unique-requests', unpack(request_keys))
  return redis.call('PFCOUNT', 'merged_unique-requests')
end

local function unique_ips(start_time, end_time)
  local ip_keys = redis.call('KEYS', 'unique-ips:*')
  redis.call('PFMERGE', 'merged_unique-ips', unpack(ip_keys))
  return redis.call('PFCOUNT', 'merged_unique-ips')
end

redis.debug("Request count: ", num_requests(0, 10000000))
redis.debug("IP request count: ", unique_ips(0, 10000000))
