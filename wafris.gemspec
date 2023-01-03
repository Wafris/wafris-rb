# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wafris/version'

Gem::Specification.new do |s|
  s.name        = 'wafris'
  s.version     = Wafris::VERSION
  s.summary     = 'Web application firewall for Rack apps'
  s.authors     = ['Micahel Buckbee', 'Ryan Castillo']
  s.files       = Dir.glob('{bin,lib}/**/*')
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.5'

  s.add_runtime_dependency 'connection_pool'
  s.add_runtime_dependency 'redis'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'rails'
  s.add_development_dependency 'railties'
  s.add_development_dependency 'rake'
end
