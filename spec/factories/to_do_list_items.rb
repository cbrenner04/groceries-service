# frozen_string_literal: true

# == Schema Information
#
# Table name: to_do_list_items
#
#  id          :uuid             not null, primary key
#  archived_at :datetime
#  category    :string
#  completed   :boolean          default(FALSE), not null
#  due_by      :datetime
#  refreshed   :boolean          default(FALSE), not null
#  task        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  assignee_id :uuid
#  list_id     :uuid             not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_to_do_list_items_on_assignee_id  (assignee_id)
#  index_to_do_list_items_on_created_at   (created_at)
#  index_to_do_list_items_on_list_id      (list_id)
#  index_to_do_list_items_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :to_do_list_item do
    user
    list { to_do_list }
    task { "MyString" }
    assignee_id { nil }
    due_by { "2017-09-24 14:35:48" }
    completed { false }
    refreshed { false }
    archived_at { nil }
    category { "MyString" }
  end
end
