class CreateGuests < ActiveRecord::Migration[8.1]
  def change
    create_table :guests do |t|
      t.string :full_name, null: false
      t.integer :companions_count, null: false, default: 0
      t.text :message
      t.bigint :principal_id, null: true

      t.timestamps
    end

    add_index :guests, :full_name
    add_index :guests, :principal_id
    add_foreign_key :guests, :guests, column: :principal_id
  end
end
