# frozen_string_literal: true

# no doc
class MusicList < List
  has_many :music_list_items, dependent: :destroy

  def categories
    music_list_items.map(&:category).concat(
      [
        "blues", "comedy", "country", "electronic", "folk", "hip hop", "jazz",
        "latin", "pop", "r&b", "rock"
      ]
    ).uniq.compact.reject(&:empty?).sort
  end
end
