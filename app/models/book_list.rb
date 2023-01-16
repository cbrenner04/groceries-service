# frozen_string_literal: true

# == Schema Information
#
# Table name: lists
#
#  id          :uuid             not null, primary key
#  archived_at :datetime
#  completed   :boolean          default(FALSE), not null
#  name        :string           not null
#  refreshed   :boolean          default(FALSE), not null
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :uuid             not null
#
# Indexes
#
#  index_lists_on_created_at  (created_at)
#  index_lists_on_owner_id    (owner_id)
#
class BookList < List
  has_many :book_list_items, foreign_key: "list_id", class_name: "BookListItem", inverse_of: :list,
                             dependent: :destroy

  def categories
    book_list_items.map(&:category).push("action & adventure", "autobiography", "biography", "crime", "drama",
                                         "fantasy", "graphic novel", "health", "historical fiction", "history",
                                         "horror", "memoir", "mystery", "poetry", "science", "science fiction",
                                         "self help", "spirituality", "textbook", "thriller", "travel",
                                         "true crime").uniq.compact_blank.sort
  end
end
