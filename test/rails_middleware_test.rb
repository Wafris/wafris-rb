# frozen_string_literal: true

require "test_helper"

if defined?(Rails)
  describe "Middleware for Rails" do
    before do
      @app = Class.new(Rails::Application) do
        config.eager_load = false
        config.logger = Logger.new(nil) # avoid creating the log/ directory automatically
        config.cache_store = :null_store # avoid creating tmp/ directory for cache
      end
    end

    it "is used by default" do
      @app.initialize!
      assert @app.middleware.include?(Wafris::Middleware)
    end
  end
end
