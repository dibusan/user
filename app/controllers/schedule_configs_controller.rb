class ScheduleConfigsController < ApplicationController

  def show_current
    render json: { success: true, schedule_config: current_user.schedule_config }
  end

  def create
    schedule = current_user.create_schedule_config(create_schedule_params)

    if schedule.persisted?
      render json: { success: true, newID: schedule.id }, status: :created
    else
      render json: { success: false, messages: schedule.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def edit
    schedule = current_user.schedule_config

    if schedule.nil?
      render json: { success: false, message: 'Current User does not have a Schedule to edit' }, status: 404
    elsif edit_schedule_params.empty?
      render json: { success: false, message: 'No fields to update' }, status: :unprocessable_entity
    elsif schedule.update(edit_schedule_params)
      render status: :no_content
    else
      render json: { success: false, messages: schedule.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def create_schedule_params
    params.permit(
      :interval_size_in_minutes,
      :day_start_time,
      :day_end_time,
      :availability_per_interval,
      :price_per_participant
    )
  end

  def edit_schedule_params
    params.permit(
      :interval_size_in_minutes,
      :day_start_time,
      :day_end_time,
      :availability_per_interval,
      :price_per_participant
    )
  end
end
