# frozen_string_literal: true

require "rails_helper"

describe "/lists/:list_id/to_do_list_items", type: :request do
  let(:user) { create :user }
  let(:list) { create :to_do_list, owner: user }
  let!(:users_list) { create :users_list, user: user, list: list }
  let(:item) { create :to_do_list_item, to_do_list: list, assignee_id: user.id }

  required_attrs = %w[task]
  item_attrs = %w[task due_by assignee_id]

  it_behaves_like "a list item", "to_do_list", required_attrs, item_attrs
end
