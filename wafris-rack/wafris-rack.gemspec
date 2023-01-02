# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wafris/version'

Gem::Specification.new do |s|
  s.name        = 'wafris-rack'
  s.version     = Wafris::VERSION
  s.summary     = 'Rack middleware for the wafris-ruby gem'
  s.authors     = ['Micahel Buckbee', 'Ryan Castillo']
  s.files       = Dir.glob('{bin,lib}/**/*')

  s.required_ruby_version = '>= 2.5'

  s.add_runtime_dependency 'wafris-ruby'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
end
