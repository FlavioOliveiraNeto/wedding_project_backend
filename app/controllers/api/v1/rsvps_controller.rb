module Api
  module V1
    class RsvpsController < ApplicationController
      before_action :set_guest

      def show
        render json: {
          full_name: @guest.full_name,
          companions: @guest.companions.map { |c| { id: c.id, full_name: c.full_name, status: c.rsvp_status } },
          status: @guest.rsvp_status,
          group_status: compute_group_status
        }
      end

      def update
        case params[:status]
        when "confirmed"
          confirm_all
        when "declined"
          decline_all
        when "partial"
          confirm_partial
        else
          return render json: { error: "Status inválido." }, status: :unprocessable_entity
        end

        render json: { success: true }
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def set_guest
        @guest = Guest.find_by!(rsvp_token: params[:token])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Convite não encontrado." }, status: :not_found
      end

      def confirm_all
        @guest.update!(rsvp_status: :confirmed)
        @guest.companions.update_all(rsvp_status: Guest.rsvp_statuses[:confirmed])
        WhatsappConfirmationNotificationService.new(@guest).call
      end

      def decline_all
        @guest.update!(rsvp_status: :declined)
        @guest.companions.update_all(rsvp_status: Guest.rsvp_statuses[:declined])
      end

      def confirm_partial
        declined_ids = Array(params[:declined_companion_ids]).map(&:to_i)
        valid_companion_ids = @guest.companions.pluck(:id)
        invalid_ids = declined_ids - valid_companion_ids

        if invalid_ids.any?
          return render json: { error: "IDs de acompanhantes inválidos." }, status: :unprocessable_entity
        end

        @guest.update!(rsvp_status: :confirmed)

        if declined_ids.any?
          @guest.companions.where(id: declined_ids).update_all(rsvp_status: Guest.rsvp_statuses[:declined])
          @guest.companions.where.not(id: declined_ids).update_all(rsvp_status: Guest.rsvp_statuses[:confirmed])
        else
          @guest.companions.update_all(rsvp_status: Guest.rsvp_statuses[:confirmed])
        end

        WhatsappConfirmationNotificationService.new(@guest).call
      end

      def compute_group_status
        all_statuses = ([@guest] + @guest.companions.to_a).map(&:rsvp_status).uniq
        return "pending" if all_statuses.any? { |s| s == "pending" }
        return "confirmed" if all_statuses.all? { |s| s == "confirmed" }
        return "declined" if all_statuses.all? { |s| s == "declined" }

        "partial"
      end
    end
  end
end
