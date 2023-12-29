# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wafris/version'

Gem::Specification.new do |s|
  s.name                   = 'wafris'
  s.version                = Wafris::VERSION
  s.summary                = 'Web Application Firewall for Rack apps'
  s.authors                = ['Micahel Buckbee', 'Ryan Castillo']
  s.files                  = Dir.glob('{bin,lib}/**/*')
  s.license                = 'Elastic-2.0'
  s.post_install_message   = <<-TEXT
    Thank you for installing the wafris gem.

    If you haven't already, please sign up for Wafris Hub at:

    https://github.com/Wafris/wafris-rb

  TEXT

  s.required_ruby_version = '>= 2.5'

  s.add_runtime_dependency 'connection_pool', '>= 2.3'
  s.add_runtime_dependency 'hiredis-client', '>= 0.19'
  s.add_runtime_dependency 'rack', '>= 2.0'
  s.add_runtime_dependency 'redis', '>= 4.8.0'

  s.add_development_dependency 'minitest', '~> 5.1'
  s.add_development_dependency 'pry', '~> 0.14', '>= 0.14.1'
  s.add_development_dependency 'rack-test', '>= 0.6'
  s.add_development_dependency 'rails', '>= 5.0'
  s.add_development_dependency 'railties', '>= 5.0'
  s.add_development_dependency 'rake', '>= 12.0'
end
