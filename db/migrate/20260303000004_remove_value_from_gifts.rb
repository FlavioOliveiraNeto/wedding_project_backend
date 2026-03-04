class RemoveValueFromGifts < ActiveRecord::Migration[8.1]
  def change
    remove_column :gifts, :value, :decimal
  end
end
