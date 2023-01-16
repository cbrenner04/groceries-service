# frozen_string_literal: true

module Users
  # override invitations controller
  class InvitationsController < Devise::InvitationsController
    include InvitableMethods
    before_action :authenticate_user!, only: :create

    def create
      # do nothing if user already exists and this isn't related to list sharing
      if invited_user && !list_id
        head :ok
      elsif list_id
        # if sharing a list, current user must have write permissions
        if current_user_has_write_access
          # if the user exists, just create the users list otherwise do the inviting and create the users list
          invited_user ? share_list(invited_user) : invite_user_with_list
        end
      else
        # if this isn't related to list sharing, just do regular invitation
        invite_user_without_list
      end
    end

    def update
      return render_password_error unless valid_accept_invitation_params?

      user = User.accept_invitation!(accept_invitation_params)
      if user.errors.empty?
        render json: { success: ["User updated."] }, status: :accepted
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def invite_params
      params.permit(:email, :invitation_token, :provider, :skip_invitation)
    end

    def accept_invitation_params
      params.permit(:password, :password_confirmation, :invitation_token)
    end

    def valid_accept_invitation_params?
      accept_invitation_params[:password] && accept_invitation_params[:password_confirmation] &&
        accept_invitation_params[:password] == accept_invitation_params[:password_confirmation]
    end

    def render_password_error
      render json: { errors: "password and password confirmation must be the same" }, status: :unprocessable_entity
    end

    def list_id
      params[:list_id]
    end

    def invited_user
      @invited_user ||= User.find_by(email: params[:email])
    end

    def existing_users_list(user)
      UsersList.find_by(user_id: user.id, list_id: list_id)
    end

    def share_list(user)
      if existing_users_list(user)
        render json: { responseText: "List already shared with #{user.email}" }, status: :conflict
      else
        users_list = create_users_list(user)
        render json: { user: user, users_list: { id: users_list.id, permissions: users_list.permissions } },
               status: :created
      end
    end

    def create_users_list(user)
      SharedListNotification.send_notification_for(current_user, user.id)
      UsersList.create!(user_id: user.id, list_id: list_id)
    end

    def current_user_has_write_access
      list = List.find(params[:list_id])
      users_list = UsersList.find_by(list: list, user: current_user)
      users_list&.permissions == "write"
    end

    def invite_user_with_list
      user = User.invite!(invite_params, current_user)
      if user.valid?
        users_list = create_users_list(user)
        render json: { user: user, users_list: { id: users_list.id, permissions: users_list.permissions } },
               status: :created
      else
        render json: user.errors, status: :unprocessable_entity
      end
    end

    def invite_user_without_list
      user = User.invite!(invite_params, current_user)
      if user.valid?
        render json: { user: user }, status: :created
      else
        render json: user.errors, status: :unprocessable_entity
      end
    end
  end
end
