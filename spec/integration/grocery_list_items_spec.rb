# frozen_string_literal: true

require "rails_helper"

describe "/lists/:list_id/list_items", type: :request do
  describe "grocery_list_items" do
    let(:user) { create(:user) }
    let(:list) { create(:grocery_list, owner: user) }
    let(:users_list) { create(:users_list, user: user, list: list) }
    let(:item) { create(:grocery_list_item, list: list) }

    it_behaves_like "a list item", "grocery_list", %w[product], %w[product quantity] do
      # let variables are inherited from parent context
    end
  end
end
