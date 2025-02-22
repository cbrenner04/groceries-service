# frozen_string_literal: true

# service object for UsersLists
class UsersListsService
  class << self
    def list_users_by_status(list_id, status)
      users_lists = UsersList.where(list_id: list_id).public_send(status)
      users_lists.map do |user_list|
        {
          user: User.find(user_list.user_id),
          users_list: {
            id: user_list.id,
            permissions: user_list.permissions
          }
        }
      end
    end

    def list_users(list_id)
      accepted_users_lists = UsersList.where(list_id: list_id).accepted
      pending_users_lists = UsersList.where(list_id: list_id).pending
      accepted_users_lists.to_a
                          .concat(pending_users_lists.to_a)
                          .map { |user_list| User.find(user_list.user_id) }
    end

    def create_users_list(user, list)
      # find first incomplete users list id
      first_incomplete_list = user.accepted_lists[:not_completed_lists].find do |l|
        UsersList.find_by(list: l, user: user).prev_id.nil?
      end
      first_incomplete_list_users_list_id = first_incomplete_list&.users_list_id || nil
      # the first incomplete users list will now be after the newly created list
      # this needs to be set on the new users list in the next_id
      new_users_list =
        UsersList.create!(user: user, list: list, has_accepted: true, next_id: first_incomplete_list_users_list_id)
      # and the first incomplete list in the prev_id
      UsersList.find(first_incomplete_list_users_list_id).update!(prev_id: new_users_list.id) if first_incomplete_list
      new_users_list
    end
  end
end
