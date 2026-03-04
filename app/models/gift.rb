class Gift < ApplicationRecord
  has_many :gift_selections, dependent: :destroy

  CATEGORIES = %w[
    quarto
    cozinha
    sala
    banheiro
    jardim
    escritorio
    decoracao
    eletronico
    outro
  ].freeze

  CATEGORY_LABELS = {
    "quarto"     => "Quarto",
    "cozinha"    => "Cozinha",
    "sala"       => "Sala",
    "banheiro"   => "Banheiro",
    "jardim"     => "Jardim",
    "escritorio" => "Escritório",
    "decoracao"  => "Decoração",
    "eletronico" => "Eletrônico",
    "outro"      => "Outro"
  }.freeze

  validates :name, presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  def sold_out?
    groups_count >= quantity
  end

  def remaining
    [ quantity - groups_count, 0 ].max
  end

  def groups_count
    if gift_selections.loaded?
      gift_selections.map(&:group_token).uniq.count
    else
      gift_selections.select(:group_token).distinct.count
    end
  end

  def category_label
    CATEGORY_LABELS.fetch(category, category.capitalize)
  end
end
