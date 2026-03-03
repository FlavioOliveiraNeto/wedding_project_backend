class WhatsappInviteService
  def initialize(guest)
    @guest = guest
  end

  def call
    WhatsappApi.send_message(
      to: @guest.phone,
      body: build_message
    )
  end

  private

  def build_message
    companion_names = @guest.companions.pluck(:full_name)

    greeting = if companion_names.any?
      "Você e #{companion_names.join(", ")} estão convidados para o nosso casamento 💍"
    else
      "Você está convidado para o nosso casamento 💍"
    end

    site_url = ENV.fetch("SITE_URL", "https://meucasamento.com")

    <<~MSG
    Olá #{@guest.full_name} ✨

    #{greeting}

    📅 Data: 04/04/2026
    🕒 Horário: 12h
    📍 Local: Espaço B eventos - Rua Dona Gercina Borges Teixeira, 720, quadra 55, lote 16, Bairro Ilda, Aparecida de Goiânia

    Confira os detalhes:
    #{site_url}

    Confirme sua presença:
    #{site_url}/rsvp/#{@guest.rsvp_token}
    MSG
  end
end
