# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.3"

gem "bootsnap", ">= 1.4.2", require: false
gem "devise", "~> 4.7", ">= 4.7.2"
gem "devise_invitable", "~> 2.0", ">= 2.0.2"
gem "devise_token_auth", "~> 1.1", ">= 1.1.4"
gem "libv8", "~> 8.4", ">= 8.4.255.0"
gem "lograge", "~> 0.11.2"
gem "newrelic_rpm", "~> 6.11", ">= 6.11.0.365"
gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 5.0"
gem "rack-cors", "~> 1.1", ">= 1.1.1"
gem "rails", "~> 6.0.3", ">= 6.0.3.3"
gem "scenic", "~> 1.5", ">= 1.5.2"
gem "secure_headers", "~> 6.3", ">= 6.3.1"
gem "sentry-raven", "~> 3.0"
gem "sprockets", "~> 3.7", ">= 3.7.2"

group :production do
  gem "informant-rails", "~> 2.2", ">= 2.2.0"
  gem "rails_12factor", "~> 0.0.3"
end

group :development, :test do
  gem "brakeman", "~> 4.9"
  gem "bundler-audit", "~> 0.7.0.1"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "database_cleaner", "~> 1.8", ">= 1.8.5"
  gem "factory_bot_rails", "~> 6.1", ">= 6.1.0"
  gem "rspec-rails", "~> 4.0", ">= 4.0.1"
  gem "rubocop", "~> 0.93.0"
  gem "rubocop-performance", "~> 1.7", ">= 1.7.1"
  gem "rubocop-rails", "~> 2.7", ">= 2.7.1"
  gem "rubocop-rspec", "~> 1.42"
  gem "simplecov", "~> 0.19.0"
end

group :development do
  gem "annotate", "~> 3.1", ">= 3.1.1"
  gem "listen", "~> 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo", "~> 2.0", ">= 2.0.2", platforms: %i[mingw mswin x64_mingw jruby]
