# frozen_string_literal: true

# no doc
class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :reject_methods

  def route_not_found
    head :not_found
  end

  private

  def reject_methods
    raise ActionController::MethodNotAllowed if %w[TRACK TRACE].include?(request.method)
  end
end
