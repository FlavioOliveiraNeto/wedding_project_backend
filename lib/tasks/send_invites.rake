namespace :wedding do
  desc "Enviar convites via WhatsApp para os responsáveis principais (cabeças de família)"
  task send_invites: :environment do
    principals = Guest.principals.where(rsvp_status: :pending)
    total = principals.count

    puts "Enviando convites para #{total} responsável(is)..."

    sent = 0
    failed = 0

    principals.find_each do |guest|
      WhatsappInviteService.new(guest).call
      puts "  ✓ Enviado para #{guest.full_name} (#{guest.phone})"
      sent += 1
    rescue => e
      puts "  ✗ Falha ao enviar para #{guest.full_name}: #{e.message}"
      failed += 1
    end

    puts "\nConcluído: #{sent} enviado(s), #{failed} falha(s)."
  end
end