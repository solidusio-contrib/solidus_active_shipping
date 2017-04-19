source "https://rubygems.org"

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem "solidus", github: "solidusio/solidus", branch: branch

gem 'solidus_auth_devise'
gem 'factory_girl_rails', '~> 4.5.0', group: :test

if branch == 'master' || branch >= "v2.0"
  gem "rails-controller-testing", group: :test
end

gem 'sqlite3'
gem 'pg'
gem 'mysql2'

group :development, :test do
  gem "pry-rails"
end

gemspec
