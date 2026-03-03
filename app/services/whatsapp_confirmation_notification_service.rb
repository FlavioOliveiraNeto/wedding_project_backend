class WhatsappConfirmationNotificationService
  def initialize(principal)
    @principal = principal
  end

  def call
    recipients = ([@principal] + @principal.companions.to_a).select(&:confirmed?)

    recipients.each do |person|
      next if person.phone.blank?

      WhatsappApi.send_message(
        to: person.phone,
        body: build_message(person)
      )
    rescue => e
      Rails.logger.error(
        "[WhatsappConfirmationNotificationService] Falha ao notificar #{person.full_name} " \
        "(#{person.phone}): #{e.message}"
      )
    end
  end

  private

  def build_message(companion)
    <<~MSG
    Olá #{companion.full_name} ✨

    Sua presença em nosso casamento foi confirmada. Ficamos muito felizes em contar com você nesse dia especial! 💍

    📅 Data: 04/04/2026
    🕒 Horário: 12h
    📍 Local: Espaço B eventos - Rua Dona Gercina Borges Teixeira, 720, quadra 55, lote 16, Bairro Ilda, Aparecida de Goiânia

    Confira os detalhes do evento:
    #{ENV['SITE_URL']}
    MSG
  end
end
