class ReplaceFullNameWithGuestIdInGiftSelections < ActiveRecord::Migration[8.1]
  def up
    # Remove seleções existentes para permitir a troca de coluna sem conflitos
    execute "DELETE FROM gift_selections"

    remove_column :gift_selections, :full_name
    add_reference :gift_selections, :guest, null: false, foreign_key: true
  end

  def down
    remove_reference :gift_selections, :guest, foreign_key: true
    add_column :gift_selections, :full_name, :string, null: false, default: ""
  end
end
