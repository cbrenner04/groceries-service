# frozen_string_literal: true

# /lists/v1_merge_lists
class V1::MergeListsController < ProtectedRouteController
  # POST /
  def create
    new_list = create_new_list
    users_list = UsersListsService.create_users_list(current_user, new_list)
    ListsService.create_new_items_from_multiple_lists(lists, new_list, current_user)
    render json: ListsService.list_response(new_list, users_list, current_user)
  end

  private

  def v1_merge_list_params
    params
      .expect(merge_lists: %i[list_ids new_list_name])
  end

  def lists
    @lists ||= List.where(id: v1_merge_list_params[:list_ids].split(","))
  end

  def list_type
    @list_type ||= lists.first[:type]
  end

  def create_new_list
    List.create(name: v1_merge_list_params[:new_list_name], owner_id: current_user.id, type: list_type)
  end
end
