# frozen_string_literal: true

require "rails_helper"
require "sentry/transport/dummy_transport"

RSpec.describe Sentry do
  let(:initializer) { Rails.root.join("config/initializers/sentry.rb") }
  let(:environment) { "production" }
  let(:dsn) { "https://public@sentry.example/1" }

  before do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(environment))
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("SENTRY_DSN").and_return(dsn)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("SENTRY_DSN").and_return(dsn)
    allow(described_class).to receive(:init).and_wrap_original do |initialize_sdk, &configure|
      initialize_sdk.call do |config|
        configure.call(config)
        config.transport.transport_class = Sentry::DummyTransport
        config.background_worker_threads = 0
        config.auto_session_tracking = false
      end
    end
  end

  after do
    described_class.close if described_class.initialized?
  end

  it "initializes the SDK in production with a configured DSN" do
    load initializer

    expect(described_class).to be_initialized
  end

  it "captures an exception with the production environment" do
    load initializer

    captured_event = described_class.capture_exception(StandardError.new("Sentry initialization smoke test"))
    event = described_class.get_current_client.transport.events.fetch(0).to_h

    expect(event).to include(
      event_id: captured_event.event_id,
      environment: "production",
      exception: a_hash_including(
        values: [a_hash_including(type: "StandardError", value: a_string_including("Sentry initialization smoke test"))]
      )
    )
  end

  context "when the DSN is missing" do
    let(:dsn) { nil }

    it "does not initialize the SDK" do
      load initializer

      expect(described_class).not_to be_initialized
    end
  end

  context "when the DSN is blank" do
    let(:dsn) { "" }

    it "does not initialize the SDK" do
      load initializer

      expect(described_class).not_to be_initialized
    end
  end

  context "when the environment is not production" do
    let(:environment) { "test" }

    it "does not initialize the SDK even with a configured DSN" do
      load initializer

      expect(described_class).not_to be_initialized
    end
  end
end
