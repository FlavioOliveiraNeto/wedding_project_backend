module Api
  module V1
    class GiftsController < ApplicationController
      def index
        gifts = Gift.includes(gift_selections: :guest).all.order(:name)

        render json: gifts.map { |gift|
          {
            id: gift.id,
            name: gift.name,
            description: gift.description,
            category: gift.category,
            category_label: gift.category_label,
            quantity: gift.quantity,
            remaining: gift.remaining,
            sold_out: gift.sold_out?,
            selected_by: selected_by_names(gift),
            purchase_url: gift.purchase_url
          }
        }
      end

      def select
        gift = Gift.includes(:gift_selections).find(params[:id])

        if gift.sold_out?
          return render json: { error: "Este presente já foi completamente selecionado." }, status: :unprocessable_entity
        end

        guest_ids = Array(params.dig(:gift_selection, :guest_ids)).map(&:to_s).map(&:strip).reject(&:blank?)

        if guest_ids.empty?
          return render json: { error: "Selecione ao menos um convidado da lista." }, status: :unprocessable_entity
        end

        guests = Guest.where(id: guest_ids)

        if guests.size != guest_ids.size
          return render json: { error: "Um ou mais convidados não foram encontrados." }, status: :unprocessable_entity
        end

        group_token = SecureRandom.hex(8)

        GiftSelection.transaction do
          guests.each do |guest|
            gift.gift_selections.create!(guest: guest, group_token: group_token)
          end
        end

        names = guests.map(&:full_name).join(" e ")
        render json: { message: "Presente selecionado com sucesso!", guest_names: names }, status: :created
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Presente não encontrado." }, status: :not_found
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def selected_by_names(gift)
        return nil unless gift.quantity == 1 && gift.sold_out?

        gift.gift_selections.map { |s| s.guest.full_name }.uniq.join(" e ")
      end
    end
  end
end
