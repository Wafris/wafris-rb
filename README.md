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
- Redis 6+
- Rails 6+
- Ruby 3+

### 1. Add the gem

Update your Gemfile to include the Wafris gem and run `bundle install`

```
# Gemfile
gem 'wafris'
```

### 2. Set your Redis Connection

By default Wafris will use the Redis instance defined in the environment variable `ENV['REDIS_URL']`

If you need to specify a different Redis location you can do so with an initalizer.

```ruby
# config/initalizers/wafris.rb

Wafris.configure do |c|
    c.redis = Redis.new(
      url: ENV['REDIS_URL']
    )
end
```

Note: depending upon your Redis provider the environment variable for your Redis connection string may be named something else.

### 3. Connect on Wafris Hub

Go to https://wafris.org/hub to login or create a new account.

- Add a new Firewall using the Redis URL you specified in step two.

Alternatively, you can add rules to your Wafris instance from the Wafris CLI - https://github.com/Wafris/wafris-cli 


## Trusted Proxies

If you have Cloudflare, Expedited WAF, or another service in front of your application that modifies the `x-forwarded-for` HTTP Request header, please review how to configure [Trusted Proxy Ranges](docs/trusted-proxies.md)

## Help / Support

For any trouble configuring Wafris please email [support@wafris.org](mailto:support@wafris.org)

Or you can book at time at: https://app.harmonizely.com/expedited/wafris 

<img src='https://uptimer.expeditedsecurity.com/wafris-rb' width='0' height='0'>
