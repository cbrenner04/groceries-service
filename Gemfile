# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.3"

gem "bootsnap", ">= 1.4.2", require: false
gem "devise", "~> 4.9", ">= 4.9.3"
gem "devise_invitable", "~> 2.0", ">= 2.0.9"
gem "devise_token_auth", "~> 1.2", ">= 1.2.3"
gem "lograge", "~> 0.14.0"
gem "newrelic_rpm", "~> 9.0", ">= 9.0.0"
gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 6.0", ">= 6.0.0"
gem "rack-cors", "~> 2.0", ">= 2.0.0"
gem "rails", "~> 7.1.0", ">= 7.1.3.4"
gem "scenic", "~> 1.8", ">= 1.8.0"
gem "secure_headers", "~> 6.3", ">= 6.3.1"
gem "sentry-rails", "~> 5.17", ">= 5.17.0"
gem "sentry-ruby", "~> 5.0"
gem "sprockets", "~> 4.2", ">= 4.2.1"

# some ruby v3 issue?
gem "net-imap", require: false
gem "net-pop", require: false
gem "net-smtp", "~> 0.5.0", require: false

group :production do
  gem "rails_12factor", "~> 0.0.3"
end

group :development, :test do
  gem "brakeman", "~> 6.0"
  gem "bundler-audit", "~> 0.9.0"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "database_cleaner", "~> 2.0", ">= 2.0.1"
  gem "factory_bot_rails", "~> 6.3", ">= 6.3.0"
  gem "rspec-rails", "~> 6.1", ">= 6.1.2"
  gem "rubocop", "~> 1.64.0"
  gem "rubocop-performance", "~> 1.21", ">= 1.21.0"
  gem "rubocop-rails", "~> 2.24", ">= 2.24.0"
  gem "rubocop-rspec", "~> 3.0", ">= 3.0.1"
  gem "simplecov", "~> 0.22.0"
end

group :development do
  gem "annotate", "~> 3.2", ">= 3.2.0"
  gem "listen", "~> 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.1.0"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo", "~> 2.0", ">= 2.0.2", platforms: %i[mingw mswin x64_mingw jruby]
