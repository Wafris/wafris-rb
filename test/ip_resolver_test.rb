# frozen_string_literal: true

require "test_helper"

class IpResolverTest < Minitest::Test
  def setup
    @mock_request = Minitest::Mock.new
    @mock_request.expect(:ip, "5.5.5.5")
  end

  def test_resolve_with_http_x_real_ip
    @mock_request.expect(:env, {"HTTP_X_REAL_IP" => "1.1.1.1"})
    @ip_resolver = Wafris::IpResolver.new(@mock_request)
    assert_equal "1.1.1.1", @ip_resolver.resolve
  end

  def test_resolve_with_http_x_true_client_ip
    @mock_request.expect(:env, {"HTTP_X_TRUE_CLIENT_IP" => "2.2.2.2"})
    @ip_resolver = Wafris::IpResolver.new(@mock_request)
    assert_equal "2.2.2.2", @ip_resolver.resolve
  end

  def test_resolve_with_http_fly_client_ip
    @mock_request.expect(:env, {"HTTP_FLY_CLIENT_IP" => "3.3.3.3"})
    @ip_resolver = Wafris::IpResolver.new(@mock_request)
    assert_equal "3.3.3.3", @ip_resolver.resolve
  end

  def test_resolve_with_http_cf_connecting_ip
    @mock_request.expect(:env, {"HTTP_CF_CONNECTING_IP" => "4.4.4.4"})
    @ip_resolver = Wafris::IpResolver.new(@mock_request)
    assert_equal "4.4.4.4", @ip_resolver.resolve
  end

  def test_resolve_fallback_to_request_ip
    @mock_request.expect(:env, {})
    @ip_resolver = Wafris::IpResolver.new(@mock_request)
    assert_equal "5.5.5.5", @ip_resolver.resolve
  end

  def test_resolve_priority_order
    @mock_request.expect(:env, {
      "HTTP_X_REAL_IP" => "1.1.1.1",
      "HTTP_X_TRUE_CLIENT_IP" => "2.2.2.2",
      "HTTP_FLY_CLIENT_IP" => "3.3.3.3",
      "HTTP_CF_CONNECTING_IP" => "4.4.4.4"
    })
    @ip_resolver = Wafris::IpResolver.new(@mock_request)
    assert_equal "1.1.1.1", @ip_resolver.resolve
  end
end
