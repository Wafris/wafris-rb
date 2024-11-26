# Wafris for Ruby/Rails 
Wafris is an open-source Web Application Firewall (WAF) that runs within Rails (and other frameworks) powered by Redis. 

Paired with [Wafris Hub](https://hub.wafris.org), you can view your site traffic in real time and and create rules to block malicious traffic from hitting your application.

![Rules and Graph](docs/rules-and-graph.png)

Rules like:

- Block IP addresses (IPv6 and IPv4) from making requests
- Block on hosts, paths, user agents, parameters, and methods
- Rate limit (throttle) requests 
- Visualize inbound traffic and requests

Need a better explanation? Read the overview at: [wafris.org](https://wafris.org)

## Installation and Configuration

The Wafris Ruby client is a gem that installs a Rack middleware into your Rails/Sinatra/Rack application filtering requests based on your created rules.

### Requirements
- Rails 5+
- Ruby 2.5+

## Setup

### 1. Connect on Wafris Hub

Go to https://wafris.org/hub to create a new account and
follow the instructions to link your Redis instance.

**Note:** In Step 3, you'll use this same Redis URL in your app configuration.

### 2. Add the gem to your application

Update your Gemfile to include the Wafris gem and run 
`bundle install`

```
# Gemfile
gem 'wafris'
```

### 3. Set your API Key
When you sign up on [Wafris Hub](https://hub.wafris.org), you'll receive your API key along with Rails instructions.

You have the option of using an Environment Variable or setting it in an initializer.

*ENV Variable:*

In your development/production environment, you'll need to set the `WAFRIS_API_KEY` environment variable to your API key.

*Initializer:*

You can also set an API key with an initializer files. Using something like `config/initializers/wafris.rb`:
```ruby
Wafris.configure do |config|
  config.api_key = 'provided key'
end
```
This is the suggested method if you want to store your API key in Rails credentials.

## v1 Migration

Version 1 of the Wafris Rails client gem is deprecated. While it will continue to work you will experience signifiant performance improvements moving to v2.

The v2 Client does not depend on a Redis instance and instead uses locally sync'd SQLite databases. If you are currently using your own Redis instance, it will continue to work, but we would recommend creating a new WAF instance on Hub and migrating your existing rules.

Update by running `bundle update wafris` and then updating your configuration.

We recommend removing your existing `config/initializers/wafris.rb` file and instead setting the `WAFRIS_API_KEY` environment variable in your production environment.

Your Wafris API key and platform specific instructions are available in the Setup section of your [Wafris Hub](https://hub.wafris.org) dashboard.


## Trusted Proxies

If you have Cloudflare, Expedited WAF, or another service in front of your application that modifies the `x-forwarded-for` HTTP Request header, please review how to configure [Trusted Proxy Ranges](docs/trusted-proxies.md)

## Help / Support

- Email: [support@wafris.org](mailto:support@wafris.org)
- Twitter: [@wafrisorg](https://twitter.com/wafrisorg)
- Booking: https://app.harmonizely.com/expedited/wafris

<img src='https://uptimer.expeditedsecurity.com/wafris-rb' width='0' height='0'>

[redis-url]: https://www.iana.org/assignments/uri-schemes/prov/redis

## Credits

Thanks to the following people who have contributed patches or helpful suggestions:

- [Matt Swanson](https://github.com/swanson)
- [Ron Shinall](https://github.com/ron-shinall)
- [Eric Bauer](https://github.com/ericbauer)
- [Jeremy Smith](jeremysmithco)
- [Sean Mitchell](https://github.com/seanwmitchell)
- [Ben Curtis](https://github.com/stympy)
