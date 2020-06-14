# frozen_string_literal: true

# no doc
class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken

  def route_not_found
    head :not_found
  end
end
