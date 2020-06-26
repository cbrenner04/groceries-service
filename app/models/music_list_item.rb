# frozen_string_literal: true

# == Schema Information
#
# Table name: music_list_items
#
#  id            :bigint           not null, primary key
#  album         :string
#  archived_at   :datetime
#  artist        :string
#  category      :string
#  purchased     :boolean          default(FALSE), not null
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  music_list_id :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_music_list_items_on_music_list_id  (music_list_id)
#  index_music_list_items_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (music_list_id => lists.id)
#  fk_rails_...  (user_id => users.id)
#
class MusicListItem < ApplicationRecord
  belongs_to :user
  belongs_to :music_list

  scope :not_purchased, (-> { where(purchased: false) })
  scope :purchased, (-> { where(purchased: true) })
  scope :not_archived, (-> { where(archived_at: nil) })

  validates :user, :music_list, presence: true
  validates :title, presence: true,
                    if: proc { |item| item.artist.blank? && item.album.blank? }
  validates :artist, presence: true,
                     if: proc { |item| item.title.blank? && item.album.blank? }
  validates :album, presence: true,
                    if: proc { |item| item.artist.blank? && item.title.blank? }
  validates :purchased, inclusion: { in: [true, false] }

  def self.ordered
    all.order(artist: :asc, album: :asc, title: :asc)
  end

  def archive
    update archived_at: Time.zone.now
  end
end
