# frozen_string_literal: true

# == Schema Information
#
# Table name: music_list_items
#
#  id          :bigint           not null, primary key
#  album       :string
#  archived_at :datetime
#  artist      :string
#  category    :string
#  purchased   :boolean          default(FALSE), not null
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  list_id     :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_music_list_items_on_list_id  (list_id)
#  index_music_list_items_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :music_list_item do
    user
    list { music_list }
    title { "MyString" }
    artist { "MyString" }
    album { "MyString" }
    purchased { false }
    archived_at { nil }
    category { "MyString" }
  end
end
