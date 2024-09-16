# frozen_string_literal: true

require 'test_helper'

class Wafris::ProxyFilterTest < Minitest::Test
  def setup
    # Clear any existing filter
    Rack::Request.ip_filter = nil
  end

  def test_set_filter_creates_lambda
    Wafris::ProxyFilter.set_filter
    assert_instance_of Proc, Rack::Request.ip_filter
  end

  def test_default_trusted_proxies
    Wafris::ProxyFilter.set_filter
    filter = Rack::Request.ip_filter

    assert filter.call('127.0.0.1'), 'should match localhost IPv4'
    assert filter.call('::1'), 'should match localhost IPv6'
    assert filter.call('10.0.0.1'), 'should match private IPv4 10.x.x.x'
    assert filter.call('172.16.0.1'), 'should match private IPv4 172.16.x.x'
    assert filter.call('192.168.0.1'), 'should match private IPv4 192.168.x.x'
    refute filter.call('8.8.8.8'), 'should not match public IP addresses'
  end

  def test_user_defined_trusted_proxies
    ENV['TRUSTED_PROXY_RANGES'] = '203.0.113.1,2001:db8::1'
    Wafris::ProxyFilter.set_filter
    filter = Rack::Request.ip_filter

    assert filter.call('203.0.113.1'), 'should match user-defined IPv4 range'
    assert filter.call('2001:db8::1'), 'should match user-defined IPv6 range'
  ensure
    ENV.delete('TRUSTED_PROXY_RANGES')
  end
end