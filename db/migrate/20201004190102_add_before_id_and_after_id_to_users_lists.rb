class AddBeforeIdAndAfterIdToUsersLists < ActiveRecord::Migration[6.0]
  def up
    add_column :users_lists, :prev_id, :uuid
    add_column :users_lists, :next_id, :uuid

    User.all.each do |user|
      pending = user.pending_lists__old__
      incomplete = user.accepted_lists__old__[:not_completed_lists]
      complete = user.all_completed_lists__old__

      [pending, incomplete, complete].each do |lists|
        lists.each_with_index do |list, index|
          prev_id = index == 0 ? nil : lists[index - 1].users_list_id
          next_id = index == lists.count - 1 ? nil : lists[index + 1].users_list_id
          UsersList.find_by(user: user, list: list).update!(prev_id: prev_id, next_id: next_id)
        end
      end
    end
  end

  def down
    remove_column :users_lists, :prev_id
    remove_column :users_lists, :next_id
  end
end
