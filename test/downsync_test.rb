

require 'test_helper'

if !ENV['WAFRIS_LOG_LEVEL']
  puts "\n\nSet WAFRIS_LOG_LEVEL to 'silent' to suppress log output in test.\n\n"
end

describe Wafris do

  before do
    # Reset environment variables before each test
    reset_environment_variables    
    @current_custom_rule_db_file = nil
    @current_data_subscription_db_file = nil
    
  end

  describe "Custom data should work from a cold start" do

    it "should confirm Modfiles exist" do
      assert(File.exist?("tmp/custom_rules.modfile"))
      assert(File.exist?("tmp/data_subscriptions.modfile"))
    end
    
    it "should confirm Modfiles contain correct db filenames" do
      assert(File.read("tmp/custom_rules.modfile").include?(".db"))
      assert(File.read("tmp/data_subscriptions.modfile").include?(".db"))
    end
    
    it "should confirm Custom Rules Lockfile cleanup" do
      refute(File.exist?("tmp/custom_rules.lockfile"))
    end
    
    it "should confirm Data Subscription Lockfile cleanup" do
      refute(File.exist?("tmp/data_subscriptions.lockfile"))
    end


  end


end