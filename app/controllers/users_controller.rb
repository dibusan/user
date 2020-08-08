class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:register]

  def register
    user = User.new(create_user_params)

    if user.save
      render json: { success: true, newUserID: user.id }, status: :created
      UserMailer.account_confirmation_email(user).deliver_later
      StripeSetupJob.perform_later(user)
    else
      render json: { success: false, messages: user.errors.full_messages }, status: :conflict
    end
  end

  def link_stripe
    if current_user.update!(stripe_acc_id: params[:stripe_acc_id])
      render status: :no_content
    else
      render json: { success: false, messages: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show_current
    render json: { success: true, user: current_user.profile }, status: :ok
  end

  def show
    user = User.find(params[:id])
    render json: { success: true, user: user.profile }, status: :ok
  end

  def edit
    user = User.find_by_id(edit_user_params[:id])

    if edit_user_params.keys.count <= 1
      # params of size 1 only contains the user id, no useful information to update
      render json: { success: false, message: 'No fields to update' }, status: :unprocessable_entity
    elsif user.nil?
      render json: { success: false, message: 'User does not exist' }, status: 404
    elsif user.update(edit_user_params)
      render status: :no_content
    else
      render json: { success: false, messages: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def delete
    user = User.find_by_id(edit_user_params[:id])

    if user.nil?
      render json: { success: false, message: 'User does not exist' }, status: 404
    else
      user.delete
      render status: :no_content
    end
  end

  private

  def create_user_params
    create_params = params.permit(:name, :email, :password, :password_confirmation, :parent_id, :role)
    create_params[:role] = User.roles[create_params[:role]]
    create_params
  end

  def token_user_params
    params.permit(:username, :password)
  end

  def edit_user_params
    params.permit(:id, :name, :email, :parent_id)
  end
end
