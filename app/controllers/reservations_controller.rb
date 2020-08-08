# frozen_string_literal: true

class ReservationsController < ApplicationController

  def create_batch
    begin
      resp = CreatePaidReservations.call(current_user, reservation_batch_params[:reservations])
      render json: { success: true, data: resp }, status: :created
    rescue StandardError => e
      Rails.logger.error e.as_json
      render json: { success: false, message: "Check application logs" }, status: :unprocessable_entity
    end
  end

  def update
    reservation = current_user.reservations.find_by_id(params[:id])

    if reservation.nil?
      render json: { success: false, message: 'Reservation does not exist' }, status: 404
    elsif reservation_params.keys.size <= 0
      render json: { success: false, message: 'No fields to update' }, status: :unprocessable_entity
    elsif reservation.update(reservation_params)
      render status: :no_content
    else
      render json: { success: false, messages: reservation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    reservation = current_user.reservations.find_by_id(params[:id])

    if reservation.nil?
      render json: { success: false, message: 'Reservation does not exist' }, status: 404
    else
      reservation.delete
      render status: :no_content
    end
  end

  def show; end

  def index
    render json: { success: true, reservations: current_user.gen_reservations }
  end

  def filter
    reservations = Reservation.where(reservation_filter_params).map(&:dto)
    render json: { success: true, reservations: reservations }
  end

  private

  def build_reservations(objects); end

  def reservation_batch_params
    params.permit(:cc_token, reservations: %i[club_id start_date end_date size reservation_type coach])
  end

  def reservation_params
    create_params = params.permit(:start_date, :end_date, :size, :reservation_type, :coach_id, :club_id)

    unless create_params[:reservation_type].nil?
      create_params[:reservation_type] =
        Reservation.reservation_types[create_params[:reservation_type]]
    end

    create_params
  end

  def reservation_filter_params
    params.permit(:club_id)
  end
end
