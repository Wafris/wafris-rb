# Trusted Proxies

CDNs, Cloud WAFs, Load balancers and some hosting providers intercept ("proxy") the HTTP requests destined for your application. 

If you're _not_ using any of the above services you can safely ignore this section. 

### How to tell if you need to set this

Beyond just knowing if you're using one of the above services you can verify the presence of the `x-forwarded-for` header with one of the following snippets. 

#### In a controller:

```ruby 
puts request.headers['X-Forwarded-For']
```

#### In a view:

```ruby
<%= request.headers['X-Forwarded-For'] %>
```

If this header is present and contains multiple IP address you need to set the Trusted Proxy Ranges.

Example:

```70.161.20.143, 185.93.229.11```


### Setting the Trusted Proxy Ranges

Wafris looks for an environment variable: `TRUSTED_PROXY_RANGES` 

The variable should contain a comma separated list of IP addresses that your trust to make requests against your application.

`TRUSTED_PROXY_RANGES=103.21.244.0,103.21.244.1  # Cloudflare IPs`

Most providers 

Note: Wafris

### X-Forwarded-For header

Services proxying traffic to your app modify the `x-forwarded-for` HTTP request header, appending their own IP address to the value stored in the header as the request is passed through each proxy.

If you're not sure if you need to set this 

This presents three problems:

1. HTTP requests headers are easily spoofed and an attacker could trivially fake IP addresses (pretending to be a proxy) to get around IP blocking rules you set in Wafris.

2. At an app level you would like to enforce receiving requests _only_ from the proxies you trust as requests coming from IP address outside of the service IP ranges you're using are most likely attacks and should be blocked.

3. Given a list of IP addresses in the header, how do we figure out what the real client IP making the request is?

All of these problems are solved by defining what proxies your application should trust which will allow Wafris to automatically sort out the requests for you. 

### 

*Trusted proxies* are IPs or ranges that we reject from tracking as they mask the real client IP.

This is a security measure to prevent clients from spoofing their IP address.

By default we accept the following as *trusted proxies*:
  * localhost IPv4 range 127.x.x.x, per RFC-3330
  * localhost IPv6 ::1
  * private IPv6 range fc00 .. fdff
  * private IPv4 range 10.x.x.x
  * private IPv4 range 172.16.0.0 .. 172.31.255.255
  * private IPv4 range 192.168.x.x
  * localhost hostname, and unix domain sockets

Depending on your setup you may have to define your own *trusted proxies*.

We do accept ranges but these have to be submitted in the form of a regex.

NOTE: If all the forwarded addresses are trusted we just return the first address,
which represents the source of the request.
