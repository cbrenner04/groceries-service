# frozen_string_literal: true

# no doc
class BookList < List
  has_many :book_list_items, dependent: :destroy

  def categories
    book_list_items.map(&:category).concat(
      [
        "action & adventure", "autobiography", "biography", "crime", "drama",
        "fantasy", "graphic novel", "health", "historical fiction", "history",
        "horror", "memoir", "mystery", "poetry", "science", "science fiction",
        "self help", "spirituality", "textbook", "thriller", "travel",
        "true crime"
      ]
    ).uniq.compact.reject(&:empty?).sort
  end
end
