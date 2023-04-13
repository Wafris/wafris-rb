# frozen_string_literal: true

require 'connection_pool'
require 'rails'
require 'redis'

require 'wafris/configuration'
require 'wafris/middleware'

require 'wafris/railtie' if defined?(Rails::Railtie)

module Wafris
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Wafris::Configuration.new
    end

    def reset
      @configuration = Wafris::Configuration.new
    end

    # ip: the IP of the client making the request, may be from x-forwarded-for
    # user_agent: full user agent making the request
    # path: path including parameters of the request
    # host: host (website/domain) making the request
    # time: UTC time of the request (from the logs to match things up)

    def allow_request?(request)
      configuration.connection_pool.with do |conn|
        time = Time.now.to_f * 1000
        status = conn.evalsha(
          configuration.core_sha,
          argv: [
            request.ip,
            IPAddr.new(request.ip).to_i,
            time.to_i
          ]
        )

        if status.eql? 'Blocked'
          return false
        else
          return true
        end
      end
    end

    def request_buckets(_now)
      graph_data = []
      configuration.connection_pool.with do |conn|
        time = Time.now.to_f * 1000
        graph_data = conn.evalsha(
          configuration.graph_sha,
          argv: [
            time.to_i
          ]
        )
      end

      return graph_data
    end

    def ips_with_num_requests
      configuration.connection_pool.with do |conn|
        return conn.zunion(
          *leader_timebuckets,
          0, -1, with_scores: true
        )
      end
    end

    private

    def leader_timebuckets
      timebuckets = []

      time = Time.now.utc
      24.times do |hours|
        timebuckets << "ip-leader-sset:#{(time - 60 * 60 * hours).strftime("%Y-%m-%d-%H")}"
      end

      return timebuckets
    end
  end
end
