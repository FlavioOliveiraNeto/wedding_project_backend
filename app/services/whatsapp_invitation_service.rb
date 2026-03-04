class WhatsappInvitationService
  def initialize(guest)
    @guest = guest
  end

  def call
    return if @guest.phone.blank?

    WhatsappApi.send_message(
      to: @guest.phone,
      body: invitation_message
    )
  end

  private

  def invitation_message
    <<~MSG
    Olá #{@guest.full_name} ✨

    Estamos muito felizes em convidar você para nosso casamento! 💍

    📅 Data: 04/04/2026
    🕒 Horário: 12h
    📍 Local: Espaço B eventos - Rua Dona Gercina Borges Teixeira, 720, quadra 55, lote 16, Bairro Ilda, Aparecida de Goiânia

    Confirme sua presença pelo link:
    #{ENV['SITE_URL']}/rsvp/#{@guest.rsvp_token}

    Esperamos você! ❤️
    MSG
  end
end