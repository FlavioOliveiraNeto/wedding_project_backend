class AllowMultipleGiftSelections < ActiveRecord::Migration[8.1]
  def change
    remove_index :gift_selections, :gift_id
    add_index :gift_selections, :gift_id
  end
end
