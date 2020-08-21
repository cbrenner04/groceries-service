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
class MusicListItem < ApplicationRecord
  belongs_to :user
  belongs_to :list, class_name: "MusicList", inverse_of: :music_list_items

  scope :not_purchased, (-> { where(purchased: false) })
  scope :purchased, (-> { where(purchased: true) })
  scope :not_archived, (-> { where(archived_at: nil) })

  validates :user, :list, presence: true
  validates :title, presence: true, if: proc { |item| item.artist.blank? && item.album.blank? }
  validates :artist, presence: true, if: proc { |item| item.title.blank? && item.album.blank? }
  validates :album, presence: true, if: proc { |item| item.artist.blank? && item.title.blank? }
  validates :purchased, inclusion: { in: [true, false] }

  def self.ordered
    all.order(artist: :asc, album: :asc, title: :asc)
  end

  def archive
    update archived_at: Time.zone.now
  end
end
