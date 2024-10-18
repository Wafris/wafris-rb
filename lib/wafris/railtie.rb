# frozen_string_literal: true

module Wafris
  class Railtie < ::Rails::Railtie
    initializer "wafris.middleware" do |app|
      app.middleware.use(Wafris::Middleware)
    end
  end
end
