# frozen_string_literal: true

require File.expand_path('lib/rack/wafris/version', __dir__)

Gem::Specification.new do |s|
  s.name = 'wafris'
  s.version     = '0.0.0'
  s.summary     = 'Ruby client for Wafrist'
  s.description = 'Manages the connection between a Ruby app and a Wafris Redis instance'
  s.authors     = ['Michael Buckbee']
  s.email       = 'support@wafris.org'
  s.files       = Dir.glob('{bin,lib}/**/*') + %w[Rakefile README.md LICENSE CHANGELOG.md]
  s.require_paths = ['lib']
  s.homepage = 'https://wafris.org'
  s.license = 'MIT'
  s.extra_rdoc_files = ['README.md']

  s.required_ruby_version = '>= 2.5'

  s.add_runtime_dependency 'connection_pool', '~> 2.2'
  s.add_runtime_dependency 'rack', '>= 1.0', '< 3'
  s.add_runtime_dependency 'redis', '~> 4.0'

  s.add_development_dependency 'dotenv', '~> 2.5'
  # s.add_development_dependency 'appraisal', '~> 2.2'
  s.add_development_dependency 'bundler', '>= 1.17', '< 3.0'
  s.add_development_dependency 'minitest', '~> 5.11'
  s.add_development_dependency 'minitest-stub-const', '~> 0.6'
  s.add_development_dependency 'rack-test', '~> 2.0'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rubocop', '~> 1.40'
  s.add_development_dependency 'rubocop-performance', '~> 1.5.0'
  s.add_development_dependency 'timecop', '~> 0.9.1'

  # byebug only works with MRI
  s.add_development_dependency 'byebug', '~> 11.0' if RUBY_ENGINE == 'ruby'
end
