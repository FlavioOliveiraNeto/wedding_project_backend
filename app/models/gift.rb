class Gift < ApplicationRecord
  has_one :gift_selection, dependent: :destroy

  validates :name, presence: true
  validates :value, numericality: { greater_than: 0 }, allow_nil: true

  def selected?
    gift_selection.present?
  end
end
