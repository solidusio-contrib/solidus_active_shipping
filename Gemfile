source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem "solidus", github: "solidusio/solidus", branch: branch

if branch == 'master' || branch >= "v2.0"
  gem "rails-controller-testing", group: :test
else
  gem "rails_test_params_backport"
end

if branch < 'v2.5'
  gem 'factory_bot', '4.10.0'
else
  gem 'factory_bot', '> 4.10.0'
end

gem 'sqlite3'
gem 'pg', '~> 0.21'
gem 'mysql2', '~> 0.4.10'

group :development, :test do
  gem 'pry-rails'
end

gemspec
