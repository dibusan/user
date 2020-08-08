class ScheduleExceptionsController < ApplicationController
  def create
    schedule_config = current_user.schedule_config
    schedule_ex = schedule_config.schedule_exceptions.new(exception_params) unless schedule_config.nil?

    if schedule_config.nil?
      render json: {
        success: false,
        message: 'Cant create schedule exception if the schedule does not exists'
      }, status: 404
    elsif schedule_ex.save
      render json: { success: true, newId: schedule_ex.id }, status: :created
    else
      render json: { success: false, messages: schedule_ex.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def edit
    schedule_ex = current_user.schedule_config.schedule_exceptions.find_by_id(exception_params[:id])

    if exception_params.keys.count <= 1
      # params of size 1 only contains the user id, no useful information to update
      render json: { success: false, message: 'No fields to update' }, status: :unprocessable_entity
    elsif schedule_ex.nil?
      render json: { success: false, message: 'Schedule Exception does not exist' }, status: 404
    elsif schedule_ex.update(exception_params)
      render status: :no_content
    else
      render json: { success: false, messages: schedule_ex.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def delete
    schedule_ex = current_user.schedule_config.schedule_exceptions.find_by_id(exception_params[:id])

    if schedule_ex.nil?
      render json: { success: false, message: 'Schedule Exception does not exist' }, status: 404
    else
      schedule_ex.delete
      render status: :no_content
    end
  end

  private

  def exception_params
    create_params = params.permit(:start_time, :end_time, :all_day, :exception_type, :price_per_participant,
                   :availability_per_interval, :id)

    # Convert exception_type from string to its enum integer
    create_params[:exception_type] =
      ScheduleException.exception_types[create_params[:exception_type]] unless create_params[:exception_type].nil?
    create_params
  end

end
