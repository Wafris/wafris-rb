# frozen_string_literal: true

require "test_helper"

module Wafris
  describe Middleware do
    it "handles local IPs as trusted proxies" do
      mocked_app = ->(_env) { [200, {}, ["OK"]] }
      middleware = Wafris::Middleware.new(mocked_app)

      # Create a mock request with a local IP and a forwarded IP
      request_env = Rack::MockRequest.env_for(
        "/",
        {
          "REMOTE_ADDR" => "127.0.0.1",
          "HTTP_X_FORWARDED_FOR" => "203.0.113.195"
        }
      )

      # Stub Wafris.evaluate to capture the IP passed to it
      captured_ip = nil
      Wafris.stub :evaluate, ->(request) do
        captured_ip = request.ip
        "Allowed"
      end do
        middleware.call(request_env)
      end

      # Assert that the forwarded IP was used, not the local IP
      assert_equal "203.0.113.195", captured_ip
    end

    it "should pass requests if no API key" do
      get "/"
      _(last_response.status).must_equal 200
    end

    it "returns 403 when treatment is Blocked" do
      mocked_app = ->(env) { [200, {}, ["OK"]] }
      middleware = Wafris::Middleware.new(mocked_app)

      Wafris.stub :evaluate, "Blocked" do
        status, headers, body = middleware.call(Rack::MockRequest.env_for("/"))
        assert_equal 403, status
        assert_equal "text/plain", headers["content-type"]
        assert_equal ["Blocked"], body
      end
    end

    it "returns 500 when treatment is unknown" do
      mocked_app = ->(env) { [200, {}, ["OK"]] }
      middleware = Wafris::Middleware.new(mocked_app)

      Wafris.stub :evaluate, "Unknown" do
        status, headers, body = middleware.call(Rack::MockRequest.env_for("/"))
        assert_equal 500, status
        assert_equal "text/plain", headers["content-type"]
        assert_equal ["Error"], body
      end
    end
  end
end
