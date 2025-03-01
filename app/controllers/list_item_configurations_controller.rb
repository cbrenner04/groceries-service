# frozen_string_literal: true

# /list_item_configurations
# controller for list item configurations
class ListItemConfigurationsController < ProtectedRouteController
  before_action :require_configuration_existence, only: %i[show edit update destroy]
  before_action :require_configuration_owner, only: %i[show edit update destroy]

  # GET /
  def index
    render json: current_user.list_item_configurations
  end

  # GET /:id
  def show
    render json: item_configuration
  end

  # GET /:id/edit
  def edit
    render json: item_configuration
  end

  # POST /
  def create
    new_item_configuration = current_user.list_item_configurations.create(item_configuration_params)
    if new_item_configuration.save
      render json: new_item_configuration
    else
      render json: new_item_configuration.errors, status: :unprocessable_entity
    end
  end

  # PUT /:id
  def update
    if item_configuration.update(item_configuration_params)
      render json: item_configuration
    else
      render json: item_configuration.errors, status: :unprocessable_entity
    end
  end

  # DELETE /:id
  def destroy
    item_configuration.list_item_field_configurations.each(&:archive)
    item_configuration.archive
    head :no_content
  end

  private

  def item_configuration
    @item_configuration ||= ListItemConfiguration.find(params[:id])
  end

  def item_configuration_params
    @item_configuration_params ||= params.expect(list_item_configuration: %i[name allow_other_users_to_view])
  end

  def require_configuration_existence
    item_configuration
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def require_configuration_owner
    head :forbidden unless item_configuration.user == current_user
  end
end
