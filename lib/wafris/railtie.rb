# frozen_string_literal: true

module Wafris
  class Railtie < ::Rails::Railtie
    initializer 'wafris.middleware' do |app|
      if Rails.version > "6" && defined?(ActionDispatch::HostAuthorization)
        app.middleware.insert_after ActionDispatch::HostAuthorization, Middleware
      else
        app.middleware.use(Wafris::Middleware)
      end
    end
  end
end
