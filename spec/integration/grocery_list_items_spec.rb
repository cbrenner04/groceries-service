# frozen_string_literal: true

require "rails_helper"

describe "/lists/:list_id/list_items", type: :request do
  describe "grocery_list_items" do
    let(:user) { create(:user) }
    let(:list) { create(:grocery_list, owner: user) }
    let(:users_list) { create(:users_list, user: user, list: list) }
    let(:item) { create(:grocery_list_item, list: list) }
    let(:required_attrs) { %w[product] }
    let(:item_attrs) { %w[product quantity] }

    it_behaves_like "a list item", "grocery_list", required_attrs, item_attrs
  end
end
