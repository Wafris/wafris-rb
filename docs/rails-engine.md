# Wait. Why isn't this a Rails Engine?

We've made a conscious decision to not make this a Rails Engine. There are a few reasons for this:

## 1. We want to support other frameworks and languages

We're not just Rails. We have in process now a Traefik plugin, direct Caddy support, .NET Razor MVC client, Elixir/Phoenix and Laravel clients.

By cleanly separating Wafris Hub from your application we can support Rails apps that start with the in Rails client and then move to using the Caddy (ex: [Hatchbox](https://hatchbox.io/)) or Traefik ([Kamal](https://kamal-deploy.org/)) clients as they grow. 

## 2. Developers don't have a great history of securing their Rails engines

This frankly terrifies us, as it's one thing to potentially leak data by failing to secure your job management web console and another to potentially allow an attacker to disable security, set rules or other compromise your application with a WAF.

## 3. We want to support SSO/MFA and configuration auditing

For compliance reasons it's important that we support SSO/MFA and other security features which we can cleanly add on to Wafris Hub without disturbing existing applications.

## 4. We want to send alerts, notifications and other messages to 

While potentially possible to allow this within an Engine it's much easier to do this in a separate hosted application. 

--- 



