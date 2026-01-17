# frozen_string_literal: true

require "rails_helper"

describe "/lists/:list_id/list_items", type: :request do
  describe "to_do_list_items" do
    let(:user) { create(:user) }
    let(:list) { create(:to_do_list, owner: user) }
    let(:users_list) { create(:users_list, user: user, list: list) }
    let(:item) { create(:to_do_list_item, list: list, assignee_id: user.id) }

    it_behaves_like "a list item", "to_do_list", %w[task], %w[task due_by assignee_id] do
      # let variables are inherited from parent context
    end
  end
end
