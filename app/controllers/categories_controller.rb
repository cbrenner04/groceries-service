# frozen_string_literal: true

# /lists/:list_id/categories
# controller for managing category options on a list
class CategoriesController < ProtectedRouteController
  before_action :require_write_access

  # POST /
  def create
    new_category = list.categories.build(name: category_params[:name])
    if new_category.save
      render json: new_category
    else
      render json: new_category.errors, status: :unprocessable_content
    end
  end

  private

  def list
    @list ||= List.find(params[:list_id])
  end

  def category_params
    @category_params ||= params.expect(category: %i[name])
  end

  def users_list
    return @users_list if defined?(@users_list)

    @users_list = UsersList.find_by(list: list, user: current_user)
  end

  def require_write_access
    head :forbidden unless users_list&.permissions == "write"
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
