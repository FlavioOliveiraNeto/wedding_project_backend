class CreateGifts < ActiveRecord::Migration[8.1]
  def change
    create_table :gifts do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :value, precision: 10, scale: 2

      t.timestamps
    end
  end
end
