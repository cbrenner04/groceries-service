# frozen_string_literal: true

if Rails.env.production? && ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV.fetch("SENTRY_DSN")
    config.environment = "production"
  end
end
