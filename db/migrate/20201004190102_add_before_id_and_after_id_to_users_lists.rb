class AddBeforeIdAndAfterIdToUsersLists < ActiveRecord::Migration[6.0]
  def up
    add_column :users_lists, :before_id, :uuid
    add_column :users_lists, :after_id, :uuid

    User.all.each do |user|
      pending = user.pending_lists
      incomplete = user.accepted_lists[:not_completed_lists]
      complete = user.all_completed_lists

      [pending, incomplete, complete].each do |lists|
        lists.each_with_index do |list, index|
          before_id = index == 0 ? nil : lists[index - 1].users_list_id
          after_id = index == lists.count - 1 ? nil : lists[index + 1].users_list_id
          UsersList.find_by(user: user, list: list).update!(before_id: before_id, after_id: after_id)
        end
      end
    end
  end

  def down
    remove_column :users_lists, :before_id
    remove_column :users_lists, :after_id
  end
end
