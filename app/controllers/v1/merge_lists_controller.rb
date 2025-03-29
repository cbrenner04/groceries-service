# frozen_string_literal: true

# /v1/lists/_merge_lists
class V1::MergeListsController < ProtectedRouteController
  # POST /
  def create
    new_list = create_new_list
    users_list = V1::UsersListsService.create_users_list(current_user, new_list)
    V1::ListsService.create_new_items_from_multiple_lists(lists, new_list, current_user)
    render json: V1::ListsService.list_response(new_list, users_list, current_user)
  end

  private

  def merge_list_params
<<<<<<< HEAD:app/controllers/merge_lists_controller.rb
    params
      .expect(merge_lists: %i[list_ids new_list_name])
=======
    params.expect(merge_lists: %i[list_ids new_list_name])
>>>>>>> 30c143d364aa433322d0614b5b805325ba020e49:app/controllers/v1/merge_lists_controller.rb
  end

  def lists
    @lists ||= List.where(id: merge_list_params[:list_ids].split(","))
  end

  def list_type
    @list_type ||= lists.first[:type]
  end

  def create_new_list
    List.create(name: merge_list_params[:new_list_name], owner_id: current_user.id, type: list_type)
  end
end
