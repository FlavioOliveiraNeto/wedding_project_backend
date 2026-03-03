class Guest < ApplicationRecord
  enum :rsvp_status, { pending: 0, confirmed: 1, declined: 2 }

  before_validation :normalize_phone
  before_create :generate_rsvp_token

  belongs_to :principal, class_name: "Guest", optional: true
  has_many :companions, class_name: "Guest", foreign_key: :principal_id, dependent: :destroy

  validates :full_name, presence: true
  validates :companions_count, presence: true,
                               numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # Telefone obrigatório apenas para o responsável principal.
  # Acompanhantes podem não ter número próprio (crianças, idosos, etc).
  validates :phone, presence: true, if: :principal?
  validates :phone, uniqueness: true, allow_blank: true
  validates :phone, format: {
    with: /\A55\d{10,11}\z/,
    message: "deve conter DDI 55 + DDD + número (ex: 5562999887766)"
  }, allow_blank: true
  validate :message_only_on_principal

  scope :principals, -> { where(principal_id: nil) }

  private

  def principal?
    principal_id.nil?
  end

  def normalize_phone
    return if phone.blank?

    # Remove tudo que não for dígito
    digits = phone.to_s.gsub(/\D/, "")

    # Adiciona DDI 55 se o número não começar com ele
    digits = "55#{digits}" unless digits.start_with?("55")

    self.phone = digits
  end

  def message_only_on_principal
    errors.add(:message, "não pode ser preenchida por um acompanhante") if principal_id.present? && message.present?
  end

  def generate_rsvp_token
    self.rsvp_token = SecureRandom.hex(16)
  end
end
