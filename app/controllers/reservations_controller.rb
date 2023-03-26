class ReservationsController < ApplicationController
  def index
    render json: Reservation.all
  end

  def show
    render json: Reservation.find(params[:id])
  end

  def create
    @reservation = Reservation.new(permitted_params)
    if @reservation.save
      render json: @reservation, status: :created
    else
      error = {title: 'Can not create the reservation', detail: @reservation.errors.full_messages }
      render json: {error: error}, status: :bad_request
    end
  end

  def update
    @reservation = Reservation.find(params[:id])
    if @reservation.update(permitted_params)
      render json: @reservation
    else
      error = {title: 'Can not update the reservation', detail: @reservation.errors.full_messages }
      render json: {error: error}, status: :bad_request
    end
  end

  def destroy
    if Reservation.find(params[:id]).destroy
      render json: {}, status: :ok
    end
  end

  private

  def permitted_params
    params.require(:reservation).permit(
      :hotel_name,
      :price,
      :currency,
      :checkin_date,
      :checkout_date,
      :guest_full_name,
      :guest_email
    )
  end
end
