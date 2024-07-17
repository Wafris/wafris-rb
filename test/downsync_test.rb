require 'test_helper'

if !ENV['WAFRIS_LOG_LEVEL']
  puts "\n\nSet WAFRIS_LOG_LEVEL to 'silent' to suppress log output in test.\n\n"
end

describe Wafris do

  before do
    # Reset environment variables before each test
    reset_environment_variables
    
    # Remove all cached files
    remove_cache_directory

  end

  describe "Custom data should work from a cold start" do

    it "should confirm no files at cold start" do
      refute(Dir.glob("tmp/wafris/*.db").any?)
      refute(File.exist?("tmp/wafris/custom_rules.modfile"))
      refute(File.exist?("tmp/wafris/data_subscriptions.modfile"))      
    end

    it "shouldn't raise exceptions if no API Key" do
      Wafris.configure do |config|
        config.api_key = nil
      end
  
      Wafris.downsync_db('custom_rules', nil)      
    end
      
    it "should successfully downsync data subscription with a good API key" do
      Wafris.configure do |config|
        config.api_key = 'wafris-client-test-api-key'
      end

      # Simulate a successful downsync operation
      db_rule_category = 'data_subscriptions'
      current_filename = nil
      lockfile_path = "#{Wafris.configuration.db_file_path}/#{db_rule_category}.lockfile"
      modfile_path = "#{Wafris.configuration.db_file_path}/#{db_rule_category}.modfile"      

      # Perform the downsync
      Wafris.downsync_db(db_rule_category, current_filename)

      # Check if the lockfile, modfile, and db file are created successfully
      assert File.exist?(modfile_path), "Modfile was not created"

      # Read the value in the modfile
      db_file_name = File.read(modfile_path)    
      #ap Wafris.configuration.db_file_path
      #ap db_file_name
      assert File.exist?(File.join(Wafris.configuration.db_file_path, db_file_name)), "DB file was not created"
      
      refute File.exist?(lockfile_path), "Lockfile should not exist"

    end

    

    # Custom Rules
      # Should create a lockfile
      # Should create a modfile
      # Should do something if api key is bad or error
      # Should create a db file if success
      # Should remove lockfile if success
      
    # Data Subscriptions
      # Should create a lockfile
      # Should create a modfile
      # Should do something if api key is bad or error
      # Should create a db file if success
      # Should remove lockfile if success
      
    # Current DB
      # Should refresh at interval
  end


end
