
# frozen_string_literal: true


require 'rails'
require 'sqlite3'
require 'ipaddr'
require 'httparty'

require 'wafris/configuration'
require 'wafris/middleware'
require 'wafris/log_suppressor'

require 'wafris/railtie' if defined?(Rails::Railtie)
ActiveSupport::Deprecation.behavior = :silence

module Wafris
  class << self
    attr_accessor :configuration

    def configure
      raise ArgumentError unless block_given?

      self.configuration ||= Wafris::Configuration.new
      
      yield(configuration)
      
      LogSuppressor.puts_log("[Wafris] Configuration settings created.")

      configuration.create_settings

    rescue ArgumentError
      puts "[Wafris] block is required to configure Wafris. More info can be found at: https://github.com/Wafris/wafris-rb"      
    
      #rescue StandardError => e
     # puts "[Wafris] firewall disabled due to: #{e.message}. Cannot connect via Wafris.configure. Please check your configuration settings. More info can be found at: https://github.com/Wafris/wafris-rb"
      
    end


    def zero_pad(number, length)
      number.to_s.rjust(length, "0")
    end
  
    def ip_to_decimal_lexical_string(ip)
      num = 0
  
      if ip.include?(":")
        ip = IPAddr.new(ip).to_string
        hex = ip.delete(":")
        (0...hex.length).step(4) do |i|
          chunk = hex[i, 4].to_i(16)
          num = num * (2**16) + chunk
        end
      elsif ip.include?(".")
        ip.split(".").each do |chunk|
          num = num * 256 + chunk.to_i
        end
      end
  
      str = num.to_s
      zero_pad(str, 39)
    end
  
    def ip_in_cidr_range(ip_address, table_name, db_connection)
      lexical_address = ip_to_decimal_lexical_string(ip_address)
      higher_value = db_connection.get_first_value("SELECT * FROM #{table_name} WHERE member > ? ORDER BY member ASC", [lexical_address])
      lower_value = db_connection.get_first_value("SELECT * FROM #{table_name} WHERE member < ? ORDER BY member DESC", [lexical_address])
  
      if higher_value.nil? || lower_value.nil?
        return nil
      else 
        higher_compare = higher_value.split("-").last
        lower_compare = lower_value.split("-").last
    
        if higher_compare == lower_compare
          return lower_compare
        else
          return nil
        end
      end
    end
  
    def get_country_code(ip, db_connection)
      country_code = ip_in_cidr_range(ip, 'country_ip_ranges', db_connection)
  
      if country_code
        country_code = country_code.split("_").first.split("G").last
        return country_code
      else 
        return "ZZ"
      end 
    end
  
    def substring_match(request_property, table_name, db_connection)
      result = db_connection.execute("SELECT entries FROM #{table_name}")
      result.flatten.each do |entry|
        if request_property.include?(entry)
          return entry
        end
      end
      return false
    end
  
    def exact_match(request_property, table_name, db_connection)
      result = db_connection.execute("SELECT entries FROM #{table_name} WHERE entries = ?", [request_property])
      return result.any?
    end
  
    def check_rate_limit(ip, path, method, db_connection)
  
      # Correctly format the SQL query with placeholders
      limiters = db_connection.execute("SELECT * FROM blocked_rate_limits WHERE path LIKE ? AND method = ?", ["%#{path}%", method])
    
      # If no rate limiters are matched
      if limiters.empty?
        return false
      end 
  
      current_timestamp = Time.now.to_i
  
      # If any rate limiters are matched
      # This implementation will block the request on any of the rate limiters
      limiters.each do |limiter|
  
        # Limiter array mapping
        # 0: id
        # 1: path
        # 2: method
        # 3: interval
        # 4: max_count
        # 5: rule_id
  
        interval = limiter[3]
        max_count = limiter[4]      
        rule_id = limiter[5]
  
        # Expire old timestamps
        @rate_limiters.each do |ip, timestamps|
          # Removes timestamps older than the interval
  
          
  
          @rate_limiters[ip] = timestamps.select { |timestamp| timestamp > current_timestamp - interval }
          
          # Remove the IP if there are no more timestamps for the IP
          @rate_limiters.delete(ip) if @rate_limiters[ip].empty?
        end
  
        # Check if the IP+Method is rate limited 
  
        if @rate_limiters[ip] && @rate_limiters[ip].length >= max_count
          # Request is rate limited
  
          
          return rule_id
  
        else
          # Request is not rate limited, so add the current timestamp
          if @rate_limiters[ip]
            @rate_limiters[ip] << current_timestamp              
          else 
            @rate_limiters[ip] = [current_timestamp]
          end
  
          return false
        end
  
      end
  
    end
  
    def send_upsync_requests(requests_array)
  
      begin
        
        headers = {'Content-Type' => 'application/json'}
        body = {batch: requests_array}.to_json
        response = HTTParty.post(@upsync_url, 
                                 :body => body, 
                                 :headers => headers, 
                                 :timeout => 300)
        if response.code == 200
          puts "Upsync successful"
          @upsync_status = 'Complete'
        else
          puts "Upsync Error. HTTP Response: #{response.code}"                
        end    
      rescue HTTParty::Error => e
        puts "Upsync Response: #{response.code}"
        puts "Failed to send upsync requests: #{e.message}"      
      end
      return true
    end
  
    # This method is used to queue upsync requests. It takes in several parameters including 
    # ip, user_agent, path, parameters, host, method, treatment, category, and rule. 
    #
    # The 'treatment' parameter represents the action taken on the request, which can be 
    # 'Allowed', 'Blocked', or 'Passed'.
    #
    # The 'category' parameter represents the category of the rule that was matched, such as 
    # 'blocked_ip', 'allowed_cidr', etc.
    #
    # The 'rule' parameter represents the specific rule that was matched within the category 
    # ex: '192.23.5.4', 'SemRush', etc.
    def queue_upsync_request(ip, user_agent, path, parameters, host, method, treatment, category, rule)
      
      if @upsync_status != 'Disabled'
  
        # Add request to the queue
        request = [ip, user_agent, path, parameters, host, method, treatment, category, rule]
        @upsync_queue << request
  
        # If the queue is full, send the requests to the upsync server
        if @upsync_queue.length >= @upsync_queue_limit || (Time.now.to_i - @last_upsync_timestamp) >= @upsync_interval
          requests_array = @upsync_queue
          @upsync_queue = []
          @last_upsync_timestamp = Time.now.to_i
  
          @upsync_status = 'Uploading'      
          send_upsync_requests(requests_array)
        end
  
        # Return the treatment - used to return 403 or 200
        return treatment
      else
        return "Passed"
      end
  
    end
  
    # Pulls the latest rules from the server
    def downsync_db(db_rule_category, current_filename = nil)
  
      lockfile_path = "#{@db_file_path}/#{db_rule_category}.lockfile"
  
      puts lockfile_path
  
      # Attempt to create a lockfile with exclusive access; skip if it exists
      begin
        lockfile = File.open(lockfile_path, File::RDWR|File::CREAT|File::EXCL)
      rescue Errno::EEXIST
        puts "Lockfile already exists, skipping downsync."
        return
      end
  
      begin
        # Actual Downsync operations
        filename = ""
  
        # Check server for new rules
        #puts "Downloading from #{@downsync_url}/#{db_rule_category}/#{@api_key}?current_version=#{current_filename}"
        uri = "#{@downsync_url}/#{db_rule_category}/#{@api_key}?current_version=#{current_filename}"
    
        response = HTTParty.get(
          uri,
          follow_redirects: true,   # Enable following redirects
          max_redirects: 2          # Maximum number of redirects to follow
        )
  
        if response.code == 401
          @upsync_status = 'Disabled'
          puts "Unauthorized: Bad or missing API key"
  
          filename = current_filename
          
        elsif response.code == 304
          @upsync_status = 'Enabled'
          puts "No new rules to download"
    
          filename = current_filename
          
        elsif response.code == 200
          @upsync_status = 'Disabled'
  
          if current_filename
            old_file_name = current_filename
          end
    
          # Extract the filename from the response
          content_disposition = response.headers['content-disposition']
          filename = content_disposition.match(/filename="(.+)"/)[1]
    
          # Save the body of the response to a new SQLite file      
          File.open(@db_file_path + "/" + filename, 'wb') { |file| file.write(response.body) }
          
          # Write the filename into the db_category.modfile
          File.open("#{@db_file_path}/#{db_rule_category}.modfile", 'w') { |file| file.write(filename) }
    
          # Remove the old database file      
          if old_file_name 
            #puts "Removing old file: #{@db_file_path}/#{old_file_name}"
            if File.exist?(@db_file_path + "/" + old_file_name)
              File.delete(@db_file_path + "/" + old_file_name) 
            end
          end
          
        end
    
      rescue Exception => e
        puts "EXCEPTION: Error downloading rules: #{e.message}"
  
      # This gets set even if the API key is bad or other issues
      # to prevent hammering the distribution server on every request
      ensure
    
        # Reset the modified time of the modfile
        unless File.exist?("#{@db_file_path}/#{db_rule_category}.modfile")
          File.new("#{@db_file_path}/#{db_rule_category}.modfile", 'w')
        end
  
        # Set the modified time of the modfile to the current time
        File.utime(Time.now, Time.now, "#{@db_file_path}/#{db_rule_category}.modfile")
    
        # Ensure the lockfile is removed after operations
        lockfile.close
        File.delete(lockfile_path)
      end
  
      return filename
  
    end
  
    # Returns the current database file, 
    # if the file is older than the interval, it will download the latest db
    # if the file doesn't exist, it will download the latest db
    # if the lockfile exists, it will return the current db
    def current_db(db_rule_category)
        
      if db_rule_category == 'custom_rules'
        interval = @downsync_custom_rules_interval
      else 
        interval = @downsync_data_subscriptions_interval
      end 
  
      # Checks for existing current modfile, which contains the current db filename
      if File.exist?("#{@db_file_path}/#{db_rule_category}.modfile")
  
        #puts "Modfile exists: #{@db_file_path}/#{db_rule_category}.modfile"
  
        # Get last Modified Time and current database file name
        last_db_synctime = File.mtime("#{@db_file_path}/#{db_rule_category}.modfile").to_i
        returned_db = File.read("#{@db_file_path}/#{db_rule_category}.modfile").strip
  
        # Check if the db file is older than the interval      
        if (Time.now.to_i - last_db_synctime) > interval
          #puts "DB file is older than the interval"
  
          # Make sure that another process isn't already downloading the rules
          if !File.exist?("#{@db_file_path}/#{db_rule_category}.lockfile")
            returned_db = downsync_db(db_rule_category, returned_db)        
          end
  
          return returned_db
  
        # Current db is up to date
        else 
  
          returned_db = File.read("#{@db_file_path}/#{db_rule_category}.modfile").strip
  
          # If the modfile is empty (no db file name), return nil
          # this can happen if the the api key is bad
          if returned_db == ""
            return nil
          else
            return returned_db
          end
  
        end
  
      # No modfile exists, so download the latest db
      else 
  
        # Make sure that another process isn't already downloading the rules
        if File.exist?("#{@db_file_path}/#{db_rule_category}.lockfile")
          # Lockfile exists, but not modfile with a db filename
          return nil
        else
  
          # No modfile exists, so download the latest db
          returned_db = downsync_db(db_rule_category, nil)
  
          if returned_db.nil?
            return nil
          else 
            return returned_db
          end
  
        end
  
      end 
  
      
  
    end
  
    # This is the main loop that evaluates the request
    # as well as sorts out when downsync and upsync should be called
    def evaluate(ip, user_agent, path, parameters, host, method)
  
        rules_db_filename = current_db('custom_rules')
        data_subscriptions_db_filename = current_db('data_subscriptions')
  
        ap "Rules path: #{rules_db_filename}"
        ap "Rules path nil: #{rules_db_filename.nil?}"
        ap "Rules path empty: #{rules_db_filename.to_s.strip == ''}"
  
        ap "Data Subscriptions path: #{data_subscriptions_db_filename}"
        ap "Data Subscriptions path nil: #{data_subscriptions_db_filename.nil?}"
        ap "Data Subscriptions path empty: #{data_subscriptions_db_filename.to_s.strip == ''}"
  
  
        if rules_db_filename.to_s.strip != '' && data_subscriptions_db_filename.strip.to_s.strip != ''
  
          rules_db = SQLite3::Database.new "#{@db_file_path}/#{rules_db_filename}"
          data_subscriptions_db = SQLite3::Database.new "#{@db_file_path}/#{data_subscriptions_db_filename}"
  
          # Allowed IPs
          if exact_match(ip, 'allowed_ips', rules_db)
            return queue_upsync_request(ip, user_agent, path, parameters, host, method, 'Allowed', 'ai', ip)
          end
  
          # Allowed CIDR Ranges
          if ip_in_cidr_range(ip, 'allowed_cidr_ranges', rules_db)
            return queue_upsync_request(ip, user_agent, path, parameters, host, method, 'Allowed', 'ac', ip)
          end
  
          # Blocked IPs
          if exact_match(ip, 'blocked_ips', rules_db)
            return queue_upsync_request(ip, user_agent, path, parameters, host, method, 'Blocked', 'bi', ip)
          end
  
          # Blocked CIDR Ranges
          if ip_in_cidr_range(ip, 'blocked_cidr_ranges', rules_db)
            return queue_upsync_request(ip, user_agent, path, parameters, host, method, 'Blocked', 'bc', ip)
          end
  
          # Blocked Country Codes
          country_code = get_country_code(ip, data_subscriptions_db)      
          if exact_match(country_code, 'blocked_country_codes', rules_db)
            return queue_upsync_request(ip, user_agent, path, parameters, host, method, 'Blocked', 'bs', "G_#{country_code}")
          end 
  
          # Blocked Reputation IP Ranges
          if ip_in_cidr_range(ip, 'reputation_ip_ranges', data_subscriptions_db)
            return queue_upsync_request(ip, user_agent, path, parameters, host, method, 'Blocked', 'bs', "R")
          end
  
          # Blocked User Agents
          user_agent_match = substring_match(user_agent, 'blocked_user_agents', rules_db)
          if user_agent_match
            return queue_upsync_request(ip, user_agent, path, parameters, host, method, 'Blocked', 'bu', user_agent_match)
          end
  
          # Blocked Paths
          path_match = substring_match(path, 'blocked_paths', rules_db)
          if path_match
            return queue_upsync_request(ip, user_agent, path, parameters, host, method, 'Blocked', 'bp', path_match)
          end
  
          # Blocked Parameters
          parameters_match = substring_match(parameters, 'blocked_parameters', rules_db)
          if parameters_match
            return queue_upsync_request(ip, user_agent, path, parameters, host, method, 'Blocked', 'ba', parameters_match)
          end
  
          # Blocked Hosts
          if exact_match(host, 'blocked_hosts', rules_db)
            return queue_upsync_request(ip, user_agent, path, parameters, host, method, 'Blocked', 'bh', host)
          end
  
          # Blocked Methods
          if exact_match(method, 'blocked_methods', rules_db)
            return queue_upsync_request(ip, user_agent, path, parameters, host, method, 'Blocked', 'bm', method)
          end
  
          # Rate Limiting
          rule_id = check_rate_limit(ip, path, method, rules_db)
          if rule_id
            return queue_upsync_request(ip, user_agent, path, parameters, host, method, 'Blocked', 'brl', rule_id)
          end
  
        end
  
        # Passed if no allow or block rules matched
        return queue_upsync_request(ip, user_agent, path, parameters, host, method, 'Passed', 'passed', '-')
      
    end # end evaluate
  
  

    def allow_request?(request)

      status = "foo"

        if status.eql? 'Blocked'
          return false
        else
          return true
        end
      
    end

  end
end
