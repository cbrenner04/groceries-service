# == Schema Information
#
# Table name: active_lists
#
#  id            :bigint
#  completed     :boolean
#  has_accepted  :boolean
#  name          :string
#  refreshed     :boolean
#  type          :string
#  created_at    :datetime
#  owner_id      :bigint
#  user_id       :bigint
#  users_list_id :bigint
#
class ActiveList < ApplicationRecord
  def readonly?
    true
  end
end
