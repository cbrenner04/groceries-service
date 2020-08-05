# frozen_string_literal: true

# /lists/bulk_share
class BulkShareController < ProtectedRouteController
  def show
    lists = List.where(id: params[:list_ids].split(","))
    render json: lists
  end

  def update; end
end
