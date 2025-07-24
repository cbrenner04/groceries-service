# frozen_string_literal: true

# /v2/lists/_merge_lists
class V2::MergeListsController < ProtectedRouteController
  # POST /
  def create
    new_list = create_new_list
    users_list = V2::UsersListsService.create_users_list(current_user, new_list)
    V2::ListsService.create_new_items_from_multiple_lists(lists, new_list, current_user)
    render json: V2::ListsService.list_response(new_list, users_list, current_user)
  end

  private

  def merge_list_params
    params.expect(merge_lists: %i[list_ids new_list_name])
  end

  def lists
    @lists ||= List.where(id: merge_list_params[:list_ids].split(","))
  end

  def list_type
    # the client is filtering to make sure all lists have the same type
    @list_type ||= lists.first[:type]
  end

  def create_new_list
    List.create(name: merge_list_params[:new_list_name], owner_id: current_user.id,
                list_item_configuration_id: lists.first.list_item_configuration_id, type: list_type)
  end
end
