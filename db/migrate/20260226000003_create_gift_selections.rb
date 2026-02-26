class CreateGiftSelections < ActiveRecord::Migration[8.1]
  def change
    create_table :gift_selections do |t|
      t.string :full_name, null: false
      t.references :gift, null: false, foreign_key: true

      t.timestamps
    end

    add_index :gift_selections, :gift_id, unique: true
  end
end
