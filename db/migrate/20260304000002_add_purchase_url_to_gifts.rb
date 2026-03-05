class AddPurchaseUrlToGifts < ActiveRecord::Migration[8.1]
  def change
    add_column :gifts, :purchase_url, :string
  end
end
