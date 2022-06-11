# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.6"

gem "bootsnap", ">= 1.4.2", require: false
gem "devise", "~> 4.8", ">= 4.8.1"
gem "devise_invitable", "~> 2.0", ">= 2.0.6"
gem "devise_token_auth", "~> 1.2", ">= 1.2.0"
gem "lograge", "~> 0.12.0"
gem "newrelic_rpm", "~> 8.0", ">= 8.0.0"
gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 5.6", ">= 5.6.4"
gem "rack-cors", "~> 1.1", ">= 1.1.1"
gem "rails", "~> 6.1.5", ">= 6.1.5.1"
gem "scenic", "~> 1.5", ">= 1.5.5"
gem "secure_headers", "~> 6.3", ">= 6.3.1"
gem "sentry-rails", "~> 5.0", ">= 5.0.0"
gem "sentry-ruby", "~> 5.0"
gem "sprockets", "~> 4.0", ">= 4.0.2"

group :production do
  gem "informant-rails", "~> 2.4", ">= 2.4.0"
  gem "rails_12factor", "~> 0.0.3"
end

group :development, :test do
  gem "brakeman", "~> 5.0"
  gem "bundler-audit", "~> 0.9.0"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "database_cleaner", "~> 2.0", ">= 2.0.0"
  gem "factory_bot_rails", "~> 6.2", ">= 6.2.0"
  gem "rspec-rails", "~> 5.0", ">= 5.0.2"
  gem "rubocop", "~> 1.30.0"
  gem "rubocop-performance", "~> 1.8", ">= 1.8.1"
  gem "rubocop-rails", "~> 2.13", ">= 2.13.2"
  gem "rubocop-rspec", "~> 2.0", ">= 2.0.0"
  gem "simplecov", "~> 0.21.0"
end

group :development do
  gem "annotate", "~> 3.1", ">= 3.1.1"
  gem "listen", "~> 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo", "~> 2.0", ">= 2.0.2", platforms: %i[mingw mswin x64_mingw jruby]
