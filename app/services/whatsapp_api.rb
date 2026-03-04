module WhatsappApi
  def self.send_message(to:, body:)
    validate_config!

    client = Twilio::REST::Client.new(
      ENV.fetch("TWILIO_ACCOUNT_SID"),
      ENV.fetch("TWILIO_AUTH_TOKEN")
    )

    from_number = ENV.fetch("TWILIO_FROM_NUMBER")
    to_e164     = to_e164(to)

    client.messages.create(
      from: "whatsapp:#{from_number}",
      to:   "whatsapp:#{to_e164}",
      body: body
    )

    Rails.logger.info("[WhatsappApi] Enviado → #{to_e164}")
  rescue Twilio::REST::RestError => e
    Rails.logger.error("[WhatsappApi] Erro #{e.code}: #{e.message} (destino: #{to})")
    raise
  rescue KeyError => e
    raise ArgumentError, "Configuração Twilio incompleta: #{e.message}"
  end

  private_class_method def self.validate_config!
    missing = %w[TWILIO_ACCOUNT_SID TWILIO_AUTH_TOKEN TWILIO_FROM_NUMBER].select do |var|
      ENV[var].blank?
    end
    raise ArgumentError, "Variáveis de ambiente ausentes: #{missing.join(", ")}" if missing.any?
  end

  private_class_method def self.to_e164(number)
    digits = number.to_s.gsub(/\D/, "")
    digits = "55#{digits}" unless digits.start_with?("55")
    "+#{digits}"
  end
end
