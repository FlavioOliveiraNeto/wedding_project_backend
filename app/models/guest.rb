class Guest < ApplicationRecord
  enum rsvp_status: {
    pending: 0,
    confirmed: 1,
    declined: 2
  }

  before_create :generate_rsvp_token

  belongs_to :principal, class_name: "Guest", optional: true
  has_many :companions, class_name: "Guest", foreign_key: :principal_id, dependent: :destroy

  validates :full_name, presence: true
  validates :companions_count, presence: true,
                               numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :message_only_on_principal

  scope :principals, -> { where(principal_id: nil) }

  private

  def message_only_on_principal
    errors.add(:message, "não pode ser preenchida por um acompanhante") if principal_id.present? && message.present?
  end

  def generate_rsvp_token
    self.rsvp_token = SecureRandom.hex(16)
  end
end
