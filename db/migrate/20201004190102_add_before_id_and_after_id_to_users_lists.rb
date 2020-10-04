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
          before = index == 0 ? nil : lists[index - 1].id
          after = index == lists.count - 1 ? nil : lists[index + 1].id
          UsersList.find_by(user_id: user.id, list: list.id).update!(before_id: before, after_id: after)
        end
      end
    end
  end

  def down
    remove_column :users_lists, :before_id
    remove_column :users_lists, :after_id
  end
end
