class AllowNullPhoneOnGuests < ActiveRecord::Migration[8.1]
  def change
    change_column_null :guests, :phone, true
  end
end
