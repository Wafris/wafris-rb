# frozen_string_literal: true

module Wafris
  class WafrisRequest
    attr_reader :ip, :user_agent, :path, :parameters, :host, :request_method,
                :headers, :body, :request_id, :request_timestamp

    def initialize(request, env)
      @ip = encode_to_utf8(IpResolver.new(request).resolve)
      @user_agent = encode_to_utf8(request.user_agent)
      @path = encode_to_utf8(request.path)
      @parameters = encode_to_utf8(Rack::Utils.build_query(request.params))
      @host = encode_to_utf8(request.host.to_s)
      @request_method = encode_to_utf8(request.request_method)
      @headers = extract_headers(env)
      @body = request.body&.read
      @request_id = env.fetch('action_dispatch.request_id', SecureRandom.uuid.to_s)
      @request_timestamp = Time.now.utc.to_i
    end

    private

    def extract_headers(env)
      env.each_with_object({}) do |(k, v), h|
        h[k] = encode_to_utf8(v) if k.start_with?('HTTP_')
      end
    end

    def encode_to_utf8(value)
      value&.dup&.force_encoding('UTF-8')
    end
  end
end
