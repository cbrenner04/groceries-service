class CreateActiveLists < ActiveRecord::Migration[6.0]
  def change
    replace_view :active_lists, version: 1
  end
end
