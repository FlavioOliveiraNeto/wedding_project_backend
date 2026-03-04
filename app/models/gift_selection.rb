class GiftSelection < ApplicationRecord
  belongs_to :gift
  belongs_to :guest
end
