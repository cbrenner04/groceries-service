# frozen_string_literal: true

# wrapper for specific list items controllers
class V2::ListItemsController < ProtectedRouteController
  before_action :require_write_access
end
