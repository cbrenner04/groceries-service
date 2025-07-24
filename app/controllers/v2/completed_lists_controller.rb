# frozen_string_literal: true

# /v2/completed_lists
class V2::CompletedListsController < ProtectedRouteController
  # GET /
  def index
    render json: {
      current_user_id: current_user.id,
      completed_lists: current_user.all_completed_lists,
      current_list_permissions: current_user.current_list_permissions
    }
  end
end
