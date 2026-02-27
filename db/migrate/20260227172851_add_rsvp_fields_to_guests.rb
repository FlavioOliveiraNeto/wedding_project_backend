class AddRsvpFieldsToGuests < ActiveRecord::Migration[8.1]
  def change
    add_column :guests, :phone, :string, null: false
    add_column :guests, :rsvp_status, :integer, default: 0, null: false
    add_column :guests, :rsvp_token, :string

    add_index :guests, :phone, unique: true
    add_index :guests, :rsvp_token, unique: true
  end
end
