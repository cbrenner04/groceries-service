# frozen_string_literal: true

# == Schema Information
#
# Table name: lists
#
#  id          :bigint           not null, primary key
#  archived_at :datetime
#  completed   :boolean          default(FALSE), not null
#  name        :string           not null
#  refreshed   :boolean          default(FALSE), not null
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :bigint           not null
#
# Indexes
#
#  index_lists_on_owner_id  (owner_id)
#
class MusicList < List
  has_many :music_list_items, dependent: :destroy

  def categories
    music_list_items
      .map(&:category)
      .concat(["blues", "comedy", "country", "electronic", "folk", "hip hop", "jazz", "latin", "pop", "r&b", "rock"])
      .uniq
      .compact
      .reject(&:empty?)
      .sort
  end
end
