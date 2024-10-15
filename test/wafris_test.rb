# frozen_string_literal: true

require "test_helper"

if !ENV["WAFRIS_LOG_LEVEL"]
  puts "\n\nSet WAFRIS_LOG_LEVEL to 'silent' to suppress log output in test.\n\n"
end

describe Wafris do
  before do
    # Reset environment variables before each test
    reset_environment_variables

    Wafris.configure do |config|
      config.api_key = "some"
    end

    @rules_db = SQLite3::Database.new "test/wafris_test_custom_rules.db"

    # The following variables are used to test the WAF rules
    # and are in the test/wafris_test.rb file - which is generated
    # from the Wafris Client Tests Ruleset

    # IPs
    @non_blocked_ipv4 = "2.2.2.2"
    @blocked_ipv4 = "1.1.1.1"
    @blocked_ipv4_allow_ips_test = "7.7.7.7"
    @blocked_ipv6_allow_cidrs_test = "2900:8805:2723:3d00:c83c:ba63:3e65:0001"
    @non_blocked_ipv6 = "2600:8805:2723:3d00:c83c:ba63:3e65:0000"
    @blocked_ipv6 = "2600:8805:2723:3d00:c83c:ba63:3e65:7a68"

    # Hosts
    @blocked_host = "blocked.com"
    @non_blocked_host = "example.com"

    # Paths
    @blocked_path = "/blocked"
    @non_blocked_path = "/nonblocked"

    # User Agents
    @blocked_user_agent = "blocked"
    @non_blocked_user_agent = "example"

    # Parameters
    @blocked_parameters = "blocked"
    @non_blocked_parameters = "example"

    # Methods
    @blocked_method = "PUT"
    @non_blocked_method = "GET"

    # Block CIDRs
    @blocked_ipv4_cidr = "3.3.3.0/8"
    @blocked_ipv6_cidr = "2600:8805:2723:3d00::/64"
    @non_blocked_ipv6_cidr = "2700:8805:2723:3d00::/64"

    @ipv4_in_blocked_cidr = "3.3.3.1"
    @ipv4_not_in_blocked_cidr = "4.4.4.4"

    @ipv6_in_blocked_cidr = "2600:8805:2723:3d00::1"
    @ipv6_not_in_blocked_cidr = "2600:8805:2723:0000::2"

    # Allow IPs
    @allowed_ipv4 = "3.3.3.9"
    @allowed_ipv6 = "2600:8805:2723:3D00:0000:0000:0000:0001"

    # Allow CIDRs
    @allowed_ipv4_cidr = "7.7.7.0/24"
    @allowed_ipv6_cidr = "2900:8805:2723:3d00::/64"

    # Allow IPs in CIDRs
    @ipv4_in_allowed_cidr = "7.7.7.1"
    @ipv6_in_allowed_cidr = "2900:8805:2723:3d00:0000:0000:0000:0001"
  end

  after do
    reset_environment_variables
    @rules_db.close
  end

  describe "#evaluate" do
    it "Happy path to allowed requests" do
      Wafris.stubs(:current_db).with { |param| param == "custom_rules" }.returns("custom_rules_db")
      Wafris.stubs(:current_db).with { |param| param == "data_subscriptions" }.returns("data_subscriptions_db")
      Wafris.stubs(:exact_match).returns(true)
      Wafris.stubs(:queue_upsync_request).returns("Allowed")
      SQLite3::Database.stubs(:new).returns("opened")

      request = Minitest::Mock.new
      request.expect(
        :data,
        { ip: @blocked_ipv4, user_agent: "Mozilla/5.0", path: "/blocked", parameter: "blocked",
          host: "blocked.com", method: "PUT", request_id: "1234", timestamp: 1234567890 }
      )
      request.expect(:ip, @blocked_ipv4)
      assert_equal "Allowed", Wafris.evaluate(request)
    end
  end

  describe "CIDR lookups should work" do
    it "should return true if the blocked IPv6 is in the allowed_cidrs list" do
      assert_equal true, !Wafris.ip_in_cidr_range(@blocked_ipv6_allow_cidrs_test, "allowed_cidr_ranges", @rules_db).nil?
    end

    it "should return true if the blocked IPv4 is in the blocked_cidrs list" do
      assert_equal true, !Wafris.ip_in_cidr_range(@ipv4_in_blocked_cidr, "blocked_cidr_ranges", @rules_db).nil?
    end

    it "should return true if the blocked IPv6 is in the blocked_cidrs list" do
      assert_equal true, !Wafris.ip_in_cidr_range(@ipv6_in_blocked_cidr, "blocked_cidr_ranges", @rules_db).nil?
    end

    it "should return false if the non-blocked IPv6 is not in the blocked_cidrs list" do
      assert_nil Wafris.ip_in_cidr_range(@non_blocked_ipv6_cidr, "blocked_cidr_ranges", @rules_db)
    end

    it "should return true if the allowed IPv4 is in the allowed_cidrs list" do
      assert_nil Wafris.ip_in_cidr_range(@allowed_ipv4_cidr, "allowed_cidr_ranges", @rules_db)
    end

    it "should return true if the allowed IPv6 is in the allowed_cidrs list" do
      assert_equal true, !Wafris.ip_in_cidr_range(@ipv6_in_allowed_cidr, "allowed_cidr_ranges", @rules_db).nil?
    end
  end

  describe "Exact Matches should work" do
    it "should return true if the blocked IPv4 is in the allowed_ips list" do
      assert_equal false, Wafris.exact_match(@blocked_ipv4_allow_ips_test, "allowed_ips", @rules_db)
    end

    it "should return false if the non-blocked IPv6 is not in the blocked_ips list" do
      assert_equal false, Wafris.exact_match(@non_blocked_ipv6, "blocked_ips", @rules_db)
    end

    it "should return true if the blocked IPv6 is in the blocked_ips list" do
      assert_equal true, Wafris.exact_match(@blocked_ipv6, "blocked_ips", @rules_db)
    end

    it "should return true if the allowed IPv6 is in the allowed_ips list" do
      assert_equal true, Wafris.exact_match(@allowed_ipv6, "allowed_ips", @rules_db)
    end

    it "should return false if the IP is not in the allowed_ips list" do
      assert_equal true, Wafris.exact_match(@allowed_ipv4, "allowed_ips", @rules_db)
    end

    it "should return false if the blocked IP is not in the allowed_ips list" do
      assert_equal false, Wafris.exact_match(@blocked_ipv4, "allowed_ips", @rules_db)
    end

    it "should return true if the blocked IP is in the blocked_ips list" do
      assert_equal true, Wafris.exact_match(@blocked_ipv4, "blocked_ips", @rules_db)
    end

    it "should return false if the non-blocked IP is not in the blocked_ips list" do
      assert_equal false, Wafris.exact_match(@non_blocked_ipv4, "blocked_ips", @rules_db)
    end

    it "should return true if the blocked Host is in the blocked_hosts list" do
      assert_equal true, Wafris.exact_match(@blocked_host, "blocked_hosts", @rules_db)
    end

    it "should return false if the non-blocked Host is not in the blocked_hosts list" do
      assert_equal false, Wafris.exact_match(@non_blocked_host, "blocked_hosts", @rules_db)
    end

    it "should return true if the blocked Method is in the blocked_methods list" do
      assert_equal true, Wafris.exact_match(@blocked_method, "blocked_methods", @rules_db)
    end

    it "should return false if the non-blocked Method is not in the blocked_methods list" do
      assert_equal false, Wafris.exact_match(@non_blocked_method, "blocked_methods", @rules_db)
    end
  end

  describe "Substring Matches should work" do
    it "should return true if the blocked Path is in the blocked_paths list" do
      assert_equal true, !Wafris.substring_match(@blocked_path, "blocked_paths", @rules_db).nil?
    end

    it "should return false if the non-blocked Path is not in the blocked_paths list" do
      assert_nil nil, Wafris.substring_match(@non_blocked_path, "blocked_paths", @rules_db)
    end

    it "should return true if the blocked User Agent is in the blocked_user_agents list" do
      assert_equal true, !Wafris.substring_match(@blocked_user_agent, "blocked_user_agents", @rules_db).nil?
    end

    it "should return false if the non-blocked User Agent is not in the blocked_user_agents list" do
      assert_nil nil, Wafris.substring_match(@non_blocked_user_agent, "blocked_user_agents", @rules_db)
    end

    it "should return true if the blocked Parameters are in the blocked_parameters list" do
      assert_equal true, !Wafris.substring_match(@blocked_parameters, "blocked_parameters", @rules_db).nil?
    end

    it "should return false if the non-blocked Parameters are not in the blocked_parameters list" do
      assert_nil nil, Wafris.substring_match(@non_blocked_parameters, "blocked_parameters", @rules_db)
    end
  end
end
