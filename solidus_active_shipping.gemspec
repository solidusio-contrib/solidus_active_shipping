# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_active_shipping'
  s.version     = '1.0.0'
  s.author      = ['Solidus Team']
  s.email       = 'contact@solidus.io'
  s.homepage    = 'http://solidus.io'
  s.summary     = 'Solidus extension for the active_shipping plugin.'
  s.description = 'Provide shipping rates and tracking for Active Merchant carriers'
  s.required_ruby_version = '>= 1.9.3'
  s.rubygems_version      = '1.3.6'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency 'solidus_core', ['> 1.0', '<3']
  s.add_dependency "solidus_support"
  s.add_dependency 'solidus_backend', ['> 1.0', '<3']
  s.add_dependency 'solidus_api', ['> 1.0', '<3']
  s.add_dependency 'active_shipping', '~> 1.13'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rspec-rails', '~> 3.5'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'database_cleaner', '~> 1.2'
  s.add_development_dependency 'capybara', '~> 2.7'
  s.add_development_dependency 'poltergeist', '~> 1.9'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'capybara-screenshot'
  s.add_development_dependency 'ffaker'
end
