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

In your production environment, you'll need to set the `WAFRIS_API_KEY` environment variable to your API key. When you sign up on [Wafris Hub](https://hub.wafris.org), you'll receive your API key along with per-platform instructions.

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
