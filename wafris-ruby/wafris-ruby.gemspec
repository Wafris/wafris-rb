# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wafris/version'

Gem::Specification.new do |s|
  s.name = 'wafris-ruby'
  s.version     = Wafris::VERSION
  s.summary     = 'Ruby client for Wafris'
  s.description = 'Manages the connection between a Ruby app and a Wafris Redis instance'
  s.authors     = ['Michael Buckbee', 'Ryan Castillo']
  s.email       = 'support@wafris.org'
  s.files       = Dir.glob('{bin,lib}/**/*')
  s.require_paths = ['lib']
  s.homepage = 'https://wafris.org'
  s.license = 'MIT'
  s.extra_rdoc_files = ['README.md']

  s.required_ruby_version = '>= 2.5'

  s.add_runtime_dependency 'connection_pool', '~> 2.2'
  s.add_runtime_dependency 'redis', '~> 4.0'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
end
