# frozen_string_literal: true

# top level controller for protected routes
class ProtectedRouteController < ApplicationController
  before_action :authenticate_user!
end
