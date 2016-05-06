source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'v1.0')
gem 'solidus', github: 'solidusio/solidus', branch: branch
gem 'sqlite3'
gem 'factory_girl_rails', '~> 4.5.0', group: :test

group :development, :test do
  gem 'ffaker'
  gem 'capybara-screenshot'
end

gem 'pg'
gem 'mysql2'

gemspec
