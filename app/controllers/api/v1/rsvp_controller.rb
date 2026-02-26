module Api
  module V1
    class RsvpController < ApplicationController
      def create
        full_name = rsvp_params[:full_name].to_s.strip
        companions_count = rsvp_params[:companions_count].to_i
        companion_names = Array(rsvp_params[:companion_names]).map { |n| n.to_s.strip }.reject(&:blank?)
        message = rsvp_params[:message]

        if full_name.blank?
          return render json: { error: "Nome completo é obrigatório." }, status: :unprocessable_entity
        end

        if Guest.exists?(full_name: full_name)
          return render json: { error: "#{full_name} já está confirmado(a) na lista de presença." }, status: :unprocessable_entity
        end

        if companions_count > 0 && companion_names.length != companions_count
          return render json: { error: "Informe o nome completo de todos os #{companions_count} acompanhante(s)." }, status: :unprocessable_entity
        end

        already_confirmed = companion_names.find { |name| Guest.exists?(full_name: name) }
        if already_confirmed
          return render json: { error: "#{already_confirmed} já está confirmado(a) na lista de presença." }, status: :unprocessable_entity
        end

        ActiveRecord::Base.transaction do
          principal = Guest.create!(
            full_name: full_name,
            companions_count: companions_count,
            message: message.presence
          )

          companion_names.each do |name|
            Guest.create!(
              full_name: name,
              companions_count: 0,
              principal_id: principal.id
            )
          end
        end

        render json: { message: "Presença confirmada com sucesso!" }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def rsvp_params
        params.require(:rsvp).permit(:full_name, :companions_count, :message, companion_names: [])
      end
    end
  end
end
