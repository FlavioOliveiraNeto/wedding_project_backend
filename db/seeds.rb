# Seeds de desenvolvimento — dados de teste para a funcionalidade de convites
#
# Execute com: rails db:seed
# Para recriar do zero: rails db:schema:load db:seed
#
# FORMATO DE TELEFONE:
# Use dígitos apenas, com DDI (55) + DDD + número.
# O modelo normaliza automaticamente (remove traços, parênteses, etc).
#
# ATENÇÃO — Twilio Sandbox:
# O Sandbox registra o número exatamente como o WhatsApp o reporta internamente.
# Alguns números brasileiros ficam sem o "9" extra no Sandbox (comportamento do
# WhatsApp com chips antigos). Em PRODUÇÃO isso não acontece — use o número completo.
# Se um envio falhar com erro 63015, verifique o formato no Sandbox Twilio.

puts "Limpando dados anteriores..."
Guest.destroy_all

puts "Criando convidados..."

# ── Família 1: cabeça com 2 acompanhantes ─────────────────────────────────────
flavio = Guest.create!(
  full_name: "Flávio de Oliveira Neto",
  phone: "556299387836",
  companions_count: 1
)
Guest.create!(full_name: "Gabriella Alves Felix Silva", phone: "556296195671", companions_count: 0, principal: flavio)

## ── Família 2: cabeça com 1 acompanhante ──────────────────────────────────────
#ana = Guest.create!(
#  full_name: "Ana Souza",
#  phone: "5562991110004",
#  companions_count: 1
#)
#Guest.create!(full_name: "Carlos Souza", phone: "5562991110005", companions_count: 0, principal: ana)
#
## ── Convidado solo (sem acompanhantes) ────────────────────────────────────────
#Guest.create!(
#  full_name: "Fernanda Lima",
#  phone: "5562991110006",
#  companions_count: 0
#)

puts ""
puts "Tokens de teste:"
Guest.principals.each do |g|
  puts "  #{g.full_name.ljust(20)} → http://localhost:5173/rsvp/#{g.rsvp_token}"
end
puts ""
puts "Pronto! #{Guest.principals.count} responsáveis, #{Guest.where.not(principal_id: nil).count} acompanhantes."
