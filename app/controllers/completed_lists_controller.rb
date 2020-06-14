# frozen_string_literal: true

# Controller for completed lists
class CompletedListsController < ProtectedRouteController
  def index
    render json: {
      completed_lists: current_user.all_completed_lists,
      current_list_permissions: current_user.current_list_permissions
    }
  end
end
