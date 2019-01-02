# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'solidus_active_shipping/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'solidus_active_shipping'
  s.version     = SolidusActiveShipping::VERSION
  s.author      = ['Solidus Team']
  s.email       = 'contact@solidus.io'
  s.homepage    = 'http://solidus.io'
  s.summary     = 'Solidus extension for the active_shipping plugin.'
  s.description = 'Provide shipping rates and tracking for Active Merchant carriers'

  s.required_ruby_version = '>= 1.9.3'
  s.rubygems_version      = '1.3.6'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  solidus_version = ['> 1.0', '< 3']

  s.add_dependency 'solidus_core', solidus_version
  s.add_dependency 'solidus_support'
  s.add_dependency 'solidus_backend', solidus_version
  s.add_dependency 'solidus_api', solidus_version
  s.add_dependency 'active_shipping', ['>= 1.13', '~> 2.1.1']

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'database_cleaner', '~> 1.3'
  s.add_development_dependency 'factory_bot', '~> 4.5'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'ffaker', '>= 1.25.0'
  s.add_development_dependency 'poltergeist', '~> 1.5'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-rails', '>= 0.3.0'
  s.add_development_dependency 'rspec-rails', '~> 3.1'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'capybara-webkit'
  s.add_development_dependency 'capybara-screenshot'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
end
