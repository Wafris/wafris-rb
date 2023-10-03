# wafris-rb

## What's Wafris?
Wafris is an open-source Web Application Firewall (WAF) that runs within your existing web framework powered by Redis.

Need a better explanation? Read the overview at: [wafris.org](https://wafris.org)

## What's the Wafris Ruby client (this repository)

The Wafris Ruby client is gem that installs a Rack middleware into your Rails/Sinatra/Rack app that adds a Web Application Firewall (WAF).

The WAF features allow you to:

- Analyze the dark traffic hitting your site
- Determine what requests should be blocked
- Block malicious IP addresses (IPv6 and IPv4) from making requests
- Can also block on hosts, paths, user agents, parameters, and methods
- Create rate limit rules
- Block by CIDR ranges
- Allow list for IPs and CIDRs
- Detect malicious traffic patterns

## Installation and Configuration

### Requirements
- Redis 4.8+
- Rails 5+
- Ruby 2.5+

If you have a previous version of one of the requirements above please let us know and we'll test it out.

### 1. Add the gem

Update your Gemfile to include the Wafris gem and run `bundle install`

```
# Gemfile
gem 'wafris'
```

#### In case you have Rack::Attack

If you have Rack::Attack already installed, it can work side by side with Wafris. We recommend including Wafris before Rack::Attack so that Wafris can capture the traffic data before it is blocked.
Then you can gradually migrate your rule set from Rack::Attack to Wafris and visualize the blocked traffic.

To ensure the order it's as simple as including the `wafris` gem before the `rack-attack` gem.

```
# Gemfile
gem 'wafris'
gem 'rack-attack'
```

to confirm that the order is correct you can run `rake middleware` and the output should look similar to the following:

<img width="573" alt="image" src="https://github.com/Wafris/wafris-rb/assets/155443/2dd9f5dc-58e6-40c2-96b6-f7b97267a039">

The key is that the `Wafris::Middleware` line shows up before the `Rack::Attack` line.

### 2. Set your Redis Connection

Specify your [`redis://` URL][redis-url] with the following initalizer. We recommend that you store the Redis URL in an
environment variable of your choosing rather than hard coding the string in the initializer.

```ruby
# config/initalizers/wafris.rb

Wafris.configure do |c|
    c.redis = Redis.new(
      # redis://<username>:<password>@<host>:<port>
      url: ENV['WAFRIS_REDIS_URL'],
      # necessary if you're using an SSL connection.
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    )
    # Max memory for your redis instance in MB. Default is 25MB.
    c.maxmemory = 30
    # Connection pool size for your redis instance. Default is 20.
    c.redis_pool_size = 25
end
```

Note that Redis defaults to the environment variable, `REDIS_URL`. So we recommend using something different especially if you're using multiple Redis instances.

#### What is maxmemory and why do I need to set it?

Most Redis instances you provision will come with some kind of max memory limit. We have features on the roadmap that will help with memory management.

### 3. Testing in Development (optional)

If you'd like to ensure that Waris is working properly you can launch your application in development. You're going to visit a path
that does not exist in your routes and would normally return a 404. Once blocked it will instead return a page with 'Blocked' and
a status code of 403.

If you're already using Redis locally we recommend that you use a separate Redis DB. Redis allows you to do this by appending
`/<db number>` to the end of your Redis URL. If you'd like to use DB 13 for example, you'd use the following:

```
redis://localhost:6379/13
```

Set a block path using the following command where `<path>` is the path you'd like to block. In the following example we're going to set
the block for any path that contains `wafris-test`:

```sh
redis-cli HSET rules-blocked-p wafris-test "This is a test rule"
```

Note that if you're using a different DB you'd use the `-n` argument to specify the DB number:

```sh
redis-cli -n 13 HSET rules-blocked-p wafris-test "This is a test rule"
```

Then visit this path in your browser: `http://localhost:3000/<path>` and you should see a page with
'blocked' and a 403 status code.

### 4. Setup a Redis instance

To push to production you'll need to setup a Redis instance. On Heroku we've tried multiple Redis providers but found the best one to be from [RedisLabs](https://redislabs.com/).

Once the instance is setup, you'll need an accessible Redis URL. You can test this connection with the following command:

```sh
redis-cli -u <Redis URL> PING
```

resulting in `PONG`.

Ensure that an environment variable (named in step 2) points to this Redis URL.

### 5. Set your Redis Key Expiration Policy

When Redis hits maxmemory it will evict keys based on the expiration policy you specify.
We recommend using the `volatile-ttl` policy. This will remove keys with expire field set to true and the shortest remaining time-to-live (TTL). We set these values in Wafris as requests are being processed.

In Heroku's Redis you'll have to do this via the following command:

```sh
heroku redis:maxmemory <heroku app name>  --policy volatile-ttl
```

In Redis Labs you can do this via the UI.

### 6. Deploy your applicaiton

When deploying your applicaiton you should see the following in your logs:

```
[Wafris] attempting firewall connection via Wafris.configure initializer.
[Wafris] firewall enabled. Connected to Redis on <host from Redis URL>. Ready to process requests. Set rules at: https://wafris.org/hub
```

If the host says `localhost` then this means that there is a mismatch between the environment variable you specified in your initializer (step 2) and the environment variable defined in your target deployment (step 4).

### 7. Connect on Wafris Hub

Go to https://wafris.org/hub to login or create a new account. Add a new Firewall using the Redis URL you specified in step 4.


## Trusted Proxies

If you have Cloudflare, Expedited WAF, or another service in front of your application that modifies the `x-forwarded-for` HTTP Request header, please review how to configure [Trusted Proxy Ranges](docs/trusted-proxies.md)

## Help / Support

For any trouble configuring Wafris please email [support@wafris.org](mailto:support@wafris.org)

Or you can book at time at: https://app.harmonizely.com/expedited/wafris

<img src='https://uptimer.expeditedsecurity.com/wafris-rb' width='0' height='0'>

[redis-url]:         https://www.iana.org/assignments/uri-schemes/prov/redis
