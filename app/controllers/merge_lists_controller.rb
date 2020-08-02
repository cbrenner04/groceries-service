# frozen_string_literal: true

# /lists/merge_lists
class MergeListsController < ProtectedRouteController
  include ListsService

  def create
    @lists = List.where(id: merge_list_params[:list_ids])
    list_type = @lists.first[:type]
    new_list = List.create(
      name: merge_list_params[:new_list_name],
      owner_id: current_user.id,
      type: list_type
    )
    users_list = create_users_list(current_user, new_list)
    accept_user_list(new_list)
    # TODO: not creating all items
    create_new_items_from_multiple_lists(@lists, new_list, list_type)
    render json: list_response(new_list, users_list)
  end

  private

  def merge_list_params
    params
      .require(:merge_lists)
      .permit(:list_ids, :new_list_name)
  end
end
