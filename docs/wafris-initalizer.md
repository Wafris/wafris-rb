# Rails Wafris Intalizer

In your Rails app the Wafris initalizer file:

- Tells Wafris where to find your Redis instance
- Allows for tuning of the Redis connection pool
- Allows for enabling quiet mode

## 1. Create the initializer file

Create a new file in your Rails app at `config/initializers/wafris.rb`

## 2. Find your Redis Connection URL

Most typically this is exposed as an environment variable in your production environment.

## 3. Copy the base configuration

Copy the following into your `wafris.rb` file:

```ruby
Wafris.configure do |c|
    c.redis = Redis.new(
      url: ENV['PUT_YOUR_REDIS_URL_HERE']
    )
end
```

## 4. Modify the url to point to your Redis instance

## 5. Manage SSL/TLS Redis connections

If you're using a self-signed certificate or a certificate that is not trusted by the Ruby runtime you'll need to add the following to your initializer:

```ruby
Wafris.configure do |c|
    c.redis = Redis.new(
      url: ENV['PUT_YOUR_REDIS_URL_HERE'],
      ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    )
end
```

**Note:** this does not disable SSL on the connection (the data is still encrypted in flight), it disables the verfication of the certificate. For instance, Heroku uses a self-signed certificate for their Redis instances and you'll need to add this to your initializer to connect.

## 6. Configure the Redis connection pool

By default Wafris will create a connection pool of 10 connections to your Redis instance. If you need to tune this you can add the following to your initializer:

```ruby
Wafris.configure do |c|
    c.redis = Redis.new(
      url: ENV['PUT_YOUR_REDIS_URL_HERE'],
      connection_pool: 25
    )
end
```

## 7. Enable quiet mode

By default Wafris will log status messages when a connection to the application console is opened. If you prefer to silence these messages, you can enable quiet mode:

```ruby
Wafris.configure do |c|
    c.redis = Redis.new(
      url: ENV['PUT_YOUR_REDIS_URL_HERE'],
    )
    c.quiet_mode = true
end
```
