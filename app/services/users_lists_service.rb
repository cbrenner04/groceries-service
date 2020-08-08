# frozen_string_literal: true

# service object for UsersLists
class UsersListsService
  def self.list_users_by_status(list_id, status)
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

  def self.list_users(list_id)
    accepted_users_lists = UsersList.where(list_id: list_id).public_send("accepted")
    pending_users_lists = UsersList.where(list_id: list_id).public_send("pending")
    accepted_users_lists.to_a
                        .concat(pending_users_lists.to_a)
                        .map { |user_list| User.find(user_list.user_id) }
  end

  def self.accept_user_list(list)
    UsersList.find_by(list: list).update!(has_accepted: true)
  end

  def self.create_users_list(user, list)
    UsersList.create!(user: user, list: list, has_accepted: true)
  end
end
