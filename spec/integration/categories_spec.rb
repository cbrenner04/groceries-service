# frozen_string_literal: true

require "rails_helper"

describe "Categories", type: :request do
  let(:user) { create(:user_with_lists) }
  let(:list) { user.lists.last }

  before { login user }

  describe "POST /lists/:list_id/categories" do
    it "creates a new category for the list" do
      expect do
        post list_categories_path(list.id), params: { category: { name: "Produce" } }, headers: auth_params
      end.to change(Category, :count).by(1)

      expect(response).to have_http_status(:success)
      category = Category.last
      expect(category.list_id).to eq(list.id)
      expect(category.name).to eq("Produce")
    end

    it "returns the created category" do
      post list_categories_path(list.id), params: { category: { name: "Dairy" } }, headers: auth_params

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["name"]).to eq("Dairy")
      expect(json["list_id"]).to eq(list.id)
    end

    it "does not create duplicate categories for the same list" do
      list.categories.create!(name: "Produce")

      expect do
        post list_categories_path(list.id), params: { category: { name: "Produce" } }, headers: auth_params
      end.not_to change(Category, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to eq("name" => ["has already been taken"])
    end

    it "allows same category name on different lists" do
      list.categories.create!(name: "Produce")
      other_list = user.lists.create!(name: "Other List", owner: user)

      expect do
        post list_categories_path(other_list.id), params: { category: { name: "Produce" } }, headers: auth_params
      end.to change(Category, :count).by(1)

      expect(response).to have_http_status(:ok)
    end

    it "requires authentication" do
      post list_categories_path(list.id), params: { category: { name: "Produce" } }

      expect(response).to have_http_status(:unauthorized)
    end

    it "requires write access to the list" do
      other_user = create(:user)
      login other_user

      post list_categories_path(list.id), params: { category: { name: "Produce" } }, headers: auth_params

      expect(response).to have_http_status(:forbidden)
    end

    it "requires category name" do
      post list_categories_path(list.id), params: { category: { name: "" } }, headers: auth_params

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns 404 for non-existent list" do
      post list_categories_path(0), params: { category: { name: "Produce" } }, headers: auth_params

      expect(response).to have_http_status(:not_found)
    end
  end
end
