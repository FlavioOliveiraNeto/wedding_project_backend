# Adaptador de envio WhatsApp via Twilio.
#
# Variáveis de ambiente necessárias (.env):
#   TWILIO_ACCOUNT_SID  → Account SID do painel Twilio
#   TWILIO_AUTH_TOKEN   → Auth Token do painel Twilio
#   TWILIO_FROM_NUMBER  → Número remetente no formato E.164: +14155238886 (sandbox)
#                         ou +55621XXXXXXXX (produção)
#
# Formato do número destino aceito (qualquer um desses é normalizado automaticamente):
#   "5562999887766"       → dígitos com DDI
#   "62999887766"         → dígitos sem DDI (55 é adicionado)
#   "(62) 9 9988-7766"    → formato de exibição (caracteres não-dígitos removidos)
#   "+5562999887766"      → E.164 completo
#
# Nota sobre o Twilio Sandbox:
#   O Sandbox registra o número exatamente como o WhatsApp o reporta internamente.
#   Alguns números brasileiros podem estar registrados sem o "9" extra (formato pré-2012).
#   Em produção (WhatsApp Business API), isso não ocorre — use o número completo.
#
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

  # Converte qualquer formato de número para E.164 (+55...)
  private_class_method def self.to_e164(number)
    digits = number.to_s.gsub(/\D/, "")
    digits = "55#{digits}" unless digits.start_with?("55")
    "+#{digits}"
  end
end
