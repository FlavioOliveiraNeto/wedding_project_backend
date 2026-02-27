class RsvpsController < ApplicationController
  before_action :set_guest

  def show
    render json: {
      full_name: @guest.full_name,
      companions: @guest.companions.pluck(:full_name),
      status: @guest.rsvp_status
    }
  end

  def update
    if params[:status] == "confirmed"
      @guest.update(rsvp_status: :confirmed)
    else
      @guest.update(rsvp_status: :declined)
    end

    render json: { success: true }
  end

  private

  def set_guest
    @guest = Guest.find_by!(rsvp_token: params[:token])
  end
end