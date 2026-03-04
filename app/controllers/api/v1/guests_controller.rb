module Api
  module V1
    class GuestsController < ApplicationController
      def search
        query = params[:q].to_s.strip

        if query.length < 2
          return render json: []
        end

        guests = Guest.where("full_name ILIKE ?", "%#{query}%")
                      .order(:full_name)
                      .limit(10)
                      .select(:id, :full_name)

        render json: guests.map { |g| { id: g.id, full_name: g.full_name } }
      end
    end
  end
end
