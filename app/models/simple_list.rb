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
class SimpleList < List
  has_many :simple_list_items, foreign_key: "list_id", class_name: "SimpleListItem", inverse_of: :list,
                               dependent: :destroy

  def categories
    simple_list_items.map(&:category).uniq.compact.reject(&:empty?).sort
  end
end
