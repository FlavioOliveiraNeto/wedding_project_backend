class WhatsappInviteService
  def initialize(guest)
    @guest = guest
  end

  def call
    message = build_message

    # Aqui você chama a API externa
    WhatsappApi.send_message(
      to: @guest.phone,
      body: message
    )
  end

  private

  def build_message
    companions = @guest.companions.pluck(:full_name)

    <<~MSG
    Olá #{@guest.full_name} ✨

    Você e #{companions.join(", ")} estão convidados para o nosso casamento 💍

    📅 Data: 04/04/2026
    🕒 Horário: 12h
    📍 Local: Espaço B eventos - Rua Dona Gercina Borges Teixeira, 720, quadra 55, lote 16, Bairro Ilda, Aparecida de Goiânia

    Confira os detalhes:
    https://meucasamento.com

    Confirme sua presença:
    https://meucasamento.com/rsvp/#{@guest.rsvp_token}
    MSG
  end
end