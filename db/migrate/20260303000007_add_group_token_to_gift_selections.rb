class AddGroupTokenToGiftSelections < ActiveRecord::Migration[8.1]
  def change
    add_column :gift_selections, :group_token, :string, null: false, default: ""
    add_index :gift_selections, :group_token
  end
end
