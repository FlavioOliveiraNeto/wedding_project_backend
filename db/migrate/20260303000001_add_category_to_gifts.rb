class AddCategoryToGifts < ActiveRecord::Migration[8.1]
  def change
    add_column :gifts, :category, :string, default: "outro", null: false
    add_index :gifts, :category
  end
end
