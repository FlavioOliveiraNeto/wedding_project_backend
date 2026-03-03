module Api
  module V1
    class GiftsController < ApplicationController
      def index
        gifts = Gift.includes(:gift_selection).all.order(:name)

        render json: gifts.map { |gift|
          {
            id: gift.id,
            name: gift.name,
            description: gift.description,
            value: gift.value,
            category: gift.category,
            category_label: gift.category_label,
            selected: gift.selected?,
            selected_by: gift.gift_selection&.full_name
          }
        }
      end

      def select
        gift = Gift.includes(:gift_selection).find(params[:id])

        if gift.selected?
          return render json: { error: "Este presente já foi selecionado por #{gift.gift_selection.full_name}." }, status: :unprocessable_entity
        end

        full_name = params.dig(:gift_selection, :full_name).to_s.strip

        if full_name.blank?
          return render json: { error: "Nome completo é obrigatório." }, status: :unprocessable_entity
        end

        gift.create_gift_selection!(full_name: full_name)

        render json: { message: "Presente selecionado com sucesso!" }, status: :created
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Presente não encontrado." }, status: :not_found
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end
