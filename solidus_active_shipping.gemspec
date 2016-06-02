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

  s.add_dependency('solidus', '~> 1.0')
  s.add_dependency('active_shipping', '~> 1.7.0')
  s.add_development_dependency 'pry'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rspec-rails', '~> 3.4'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'database_cleaner', '~> 1.2'
  s.add_development_dependency 'capybara', '~> 2.7'
  s.add_development_dependency 'poltergeist', '~> 1.9'
  s.add_development_dependency 'vcr'
  s.add_dependency 'carmen', '~> 1.0.0'
end
