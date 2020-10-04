# frozen_string_literal: true

# == Schema Information
#
# Table name: active_lists
#
#  id            :uuid
#  completed     :boolean
#  has_accepted  :boolean
#  name          :string
#  refreshed     :boolean
#  type          :string
#  created_at    :datetime
#  after_id      :uuid
#  before_id     :uuid
#  owner_id      :uuid
#  user_id       :uuid
#  users_list_id :uuid
#
class ActiveList < ApplicationRecord
  def readonly?
    true
  end
end
