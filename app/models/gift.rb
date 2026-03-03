class Gift < ApplicationRecord
  has_one :gift_selection, dependent: :destroy

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
  validates :value, numericality: { greater_than: 0 }, allow_nil: true
  validates :category, inclusion: { in: CATEGORIES }

  def selected?
    gift_selection.present?
  end

  def category_label
    CATEGORY_LABELS.fetch(category, category.capitalize)
  end
end
