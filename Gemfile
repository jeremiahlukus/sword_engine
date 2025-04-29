source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails"

gem "importmap-rails"
gem "lamby"
gem "mysql2", "~> 0.5"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "jbuilder"
gem 'devise'
gem 'pundit'
gem 'redis'
gem 'lambdakiq'

group :development, :test do
  gem "debug"
  gem "webrick"
  gem 'rspec-rails'
  gem 'rubocop', require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

group :production do
  gem 'lograge'
end
