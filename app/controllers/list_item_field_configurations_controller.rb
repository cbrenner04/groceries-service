# frozen_string_literal: true

# /list_item_configurations/:list_item_configuration_id/list_item_field_configurations
# controller for list item configurations
class ListItemFieldConfigurationsController < ProtectedRouteController
  before_action :require_item_configuration_existence
  before_action :require_item_field_configuration_existence, only: %i[show edit update destroy]

  # GET /
  def index
    render json: list_item_configuration.list_item_field_configurations
  end

  # GET /:id
  def show
    render json: list_item_field_configuration
  end

  # GET /:id/edit
  def edit
    render json: list_item_field_configuration
  end

  # POST /
  def create
    new_field_config =
      list_item_configuration.list_item_field_configurations.create(list_item_field_configuration_params)
    if new_field_config.save
      render json: new_field_config
    else
      render json: new_field_config.errors, status: :unprocessable_entity
    end
  end

  # PUT /:id
  def update
    if list_item_field_configuration.update(list_item_field_configuration_params)
      render json: list_item_field_configuration
    else
      render json: list_item_field_configuration.errors, status: :unprocessable_entity
    end
  end

  # DELETE /:id
  def destroy
    list_item_field_configuration.archive
    head :no_content
  end

  private

  def list_item_configuration
    @list_item_configuration ||= ListItemConfiguration.find(params[:list_item_configuration_id])
  end

  def list_item_field_configuration
    @list_item_field_configuration ||= ListItemFieldConfiguration.find(params[:id])
  end

  def list_item_field_configuration_params
    @list_item_field_configuration_params ||=
      params.expect(list_item_field_configuration: %i[label data_type position])
  end

  def require_item_configuration_existence
    head :forbidden unless list_item_configuration&.user == current_user
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def require_item_field_configuration_existence
    list_item_field_configuration
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
