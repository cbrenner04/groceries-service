# frozen_string_literal: true

require "simplecov"
SimpleCov.start "rails" do
  add_filter "app/models/active_list.rb"
end
SimpleCov.minimum_coverage 99
SimpleCov.minimum_coverage_by_file 99

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)

abort("The Rails environment is running in production") if Rails.env.production?
require "rspec/rails"
require "factory_bot_rails"
require "authentication_helper"

Warden.test_mode!

ActiveRecord::Migration.maintain_test_schema!

# Load shared examples
Rails.root.glob("spec/integration/shared_examples/**/*.rb").each { |f| require f }

RSpec.configure do |config|
  include Warden::Test::Helpers
  include AuthenticationHelper

  config.example_status_persistence_file_path = "spec/examples.txt"
  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }
  config.before { DatabaseCleaner.strategy = :transaction }
  config.before { DatabaseCleaner.start }
  config.after { DatabaseCleaner.clean }
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods
end
