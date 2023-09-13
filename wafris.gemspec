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

    https://wafris.org

  TEXT

  s.required_ruby_version = '>= 2.5'

  s.add_runtime_dependency 'connection_pool', '~> 2.3', '>= 2.3.0'
  s.add_runtime_dependency 'rack', '~> 2.0'
  s.add_runtime_dependency 'redis', '>= 4.8.0'

  s.add_development_dependency 'minitest', '~> 5.1'
  s.add_development_dependency 'pry', '~> 0.14', '>= 0.14.1'
  s.add_development_dependency 'rack-test', '~> 2.0', '>= 2.0.2'
  s.add_development_dependency 'rails', '~> 7.0', '>= 7.0.4'
  s.add_development_dependency 'railties', '~> 7.0', '>= 7.0.4'
  s.add_development_dependency 'rake', '~> 13.0', '>= 13.0.6'
end
