namespace :wedding do
  desc "Enviar convites via WhatsApp"
  task send_invites: :environment do
    Guest.where(rsvp_status: :pending).find_each do |guest|
      WhatsappInviteService.new(guest).call
      puts "Enviado para #{guest.full_name}"
    end
  end
end