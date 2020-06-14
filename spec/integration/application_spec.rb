# frozen_string_literal: true

require "rails_helper"

describe "/", type: :request do
  it "responds with not found when route not found" do
    get "/foo"

    expect(response).to have_http_status :not_found
  end
end
