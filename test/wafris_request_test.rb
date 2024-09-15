require 'test_helper'

class WafrisRequestTest < Minitest::Test
  def setup
    @mock_request = Minitest::Mock.new
    @mock_request.expect(:user_agent, 'MockAgent')
    @mock_request.expect(:path, '/test')
    @mock_request.expect(:params, {'foo' => 'bar'})
    @mock_request.expect(:host, 'example.com')
    @mock_request.expect(:request_method, 'GET')
    @mock_request.expect(:body, StringIO.new('test body'))
    @mock_env = {
      'HTTP_USER_AGENT' => 'MockAgent',
      'HTTP_HOST' => 'example.com',
      'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => '/test',
      'QUERY_STRING' => 'foo=bar',
      'action_dispatch.request_id' => '123456',
      'rack.input' => StringIO.new('test body')
    }
    @ip_resolver = Minitest::Mock.new
    @ip_resolver.expect(:resolve, '127.0.0.1')
  end

  def test_initialization
    Time.stub :now, Time.at(1234567890) do
      Wafris::IpResolver.stub(:new, @ip_resolver) do
        wafris_request = Wafris::WafrisRequest.new(@mock_request, @mock_env)

        assert_equal '127.0.0.1', wafris_request.ip
        assert_equal 'MockAgent', wafris_request.user_agent
        assert_equal '/test', wafris_request.path
        assert_equal 'foo=bar', wafris_request.parameters
        assert_equal 'example.com', wafris_request.host
        assert_equal 'GET', wafris_request.request_method
        assert_equal({'HTTP_USER_AGENT' => 'MockAgent', 'HTTP_HOST' => 'example.com'}, wafris_request.headers)
        assert_equal 'test body', wafris_request.body
        assert_equal '123456', wafris_request.request_id
        assert_equal 1234567890, wafris_request.request_timestamp
      end
    end

    @mock_request.verify
  end

  def test_request_id_fallback
    @mock_env.delete('action_dispatch.request_id')
    
    SecureRandom.stub :uuid, '987654321' do
      Wafris::IpResolver.stub(:new, @ip_resolver) do
        wafris_request = Wafris::WafrisRequest.new(@mock_request, @mock_env)
        assert_equal '987654321', wafris_request.request_id
      end
    end
  end

  def test_encode_to_utf8
    non_utf8_string = "test".force_encoding('ASCII-8BIT')
    @mock_env['HTTP_X_TEST'] = non_utf8_string

    Wafris::IpResolver.stub(:new, @ip_resolver) do
      wafris_request = Wafris::WafrisRequest.new(@mock_request, @mock_env)
      assert_equal 'UTF-8', wafris_request.headers['HTTP_X_TEST'].encoding.to_s
      assert_equal 'test', wafris_request.headers['HTTP_X_TEST']
    end
  end
end