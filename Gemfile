# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

gem "bootsnap", ">= 1.4.2", require: false
gem "devise", "~> 4.8", ">= 4.8.1"
gem "devise_invitable", "~> 2.0", ">= 2.0.6"
gem "devise_token_auth", "~> 1.2", ">= 1.2.1"
gem "lograge", "~> 0.12.0"
gem "newrelic_rpm", "~> 8.0", ">= 8.0.0"
gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 6.0", ">= 6.0.0"
gem "rack-cors", "~> 1.1", ">= 1.1.1"
gem "rails", "~> 7.0.4"
gem "scenic", "~> 1.6", ">= 1.6.0"
gem "secure_headers", "~> 6.3", ">= 6.3.1"
gem "sentry-rails", "~> 5.5", ">= 5.5.0"
gem "sentry-ruby", "~> 5.0"
gem "sprockets", "~> 4.0", ">= 4.0.2"

# some ruby v3 issue?
gem "net-imap", require: false
gem "net-pop", require: false
gem "net-smtp", "~> 0.3.1", require: false

group :production do
  gem "informant-rails", "~> 2.5", ">= 2.5.0"
  gem "rails_12factor", "~> 0.0.3"
end

group :development, :test do
  gem "brakeman", "~> 5.0"
  gem "bundler-audit", "~> 0.9.0"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "database_cleaner", "~> 2.0", ">= 2.0.0"
  gem "factory_bot_rails", "~> 6.2", ">= 6.2.0"
  gem "rspec-rails", "~> 6.0", ">= 6.0.1"
  gem "rubocop", "~> 1.42.0"
  gem "rubocop-performance", "~> 1.8", ">= 1.8.1"
  gem "rubocop-rails", "~> 2.15", ">= 2.15.2"
  gem "rubocop-rspec", "~> 2.0", ">= 2.0.0"
  gem "simplecov", "~> 0.21.0"
end

group :development do
  gem "annotate", "~> 3.1", ">= 3.1.1"
  gem "listen", "~> 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.1.0"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo", "~> 2.0", ">= 2.0.2", platforms: %i[mingw mswin x64_mingw jruby]
