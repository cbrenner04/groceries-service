# frozen_string_literal: true

# Rails 7+ raises ActionController::Redirecting::UnsafeRedirectError on
# cross-host redirects unless allow_other_host is passed. devise_token_auth
# (as of 1.2.6) hardcodes redirect_options to {}, which 500s the password
# reset flow when redirecting from the API host to the frontend.
Rails.application.config.to_prepare do
  DeviseTokenAuth::ApplicationController.class_eval do
    def redirect_options
      { allow_other_host: true }
    end
  end
end
