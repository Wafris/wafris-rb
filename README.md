# wafris-rb

## Defining your trusted proxies

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

Depending on your setup you may have to define your own *trusted proxies*. We allow this via
a `MY_PROXIES` environment variable that you can set to a comma separated list of IPs.

`MY_PROXIES=103.21.244.0,103.21.244.1  # Cloudflare IPs`

We do accept ranges but these have to be submitted in the form of a regex.

NOTE: If all the forwarded addresses are trusted we just return the first address,
which represents the source of the request.
