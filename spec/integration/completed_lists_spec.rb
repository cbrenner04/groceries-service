# frozen_string_literal: true

require "rails_helper"

describe "/completed_lists", type: :request do
  let(:user) { create :user_with_lists }

  before do
    login user
  end

  describe "GET /" do
    it "responds with success and correct payload" do
      completed_list = user.lists[0]
      completed_list.update!(completed: true)

      get completed_lists_path, headers: auth_params

      response_body = JSON.parse(response.body).to_h
      expect(response).to have_http_status :success
      expect(response_body["completed_lists"].count)
        .to eq user.all_completed_lists.count
      expect(response_body["completed_lists"].first).to eq(
        "id" => completed_list[:id],
        "name" => completed_list[:name],
        "created_at" => completed_list[:created_at].iso8601(3),
        "completed" => true,
        "refreshed" => completed_list[:refreshed],
        "owner_id" => completed_list[:owner_id],
        "users_list_id" =>
          UsersList.find_by(user_id: user.id, list_id: completed_list.id).id,
        "user_id" => user.id,
        "has_accepted" => true,
        "type" => completed_list[:type]
      )
      expect(response_body["current_list_permissions"]).to eq(
        user.lists[0].id.to_s => "write",
        user.lists[1].id.to_s => "write",
        user.lists[2].id.to_s => "write",
        user.lists[3].id.to_s => "write",
        user.lists[4].id.to_s => "write"
      )
    end
  end
end
