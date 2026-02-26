class GiftSelection < ApplicationRecord
  belongs_to :gift

  validates :full_name, presence: true
  validates :gift_id, uniqueness: { message: "já foi selecionado" }
end
