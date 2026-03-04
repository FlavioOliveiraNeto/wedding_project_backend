class ResetCompanionsCountCache < ActiveRecord::Migration[8.1]
  def up
    Guest.where(principal_id: nil).find_each do |principal|
      Guest.reset_counters(principal.id, :companions)
    end
  end

  def down
  end
end
