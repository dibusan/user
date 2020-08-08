class QuickAuthController < ApplicationController
  skip_before_action :authenticate_request

  def user1_auth
    email = "user1@testmail.com"
    pass = "123123"
    auth(email, pass)
  end

  def club1_auth
    email = "club1@testmail.com"
    pass = "123123"
    auth(email, pass)
  end

  private

  def auth(email, pass)
    command = AuthenticateUser.call(email, pass)

    if command.success?
      render json: { auth_token: command.result }
    else
      render json: { error: command.errors.full_messages }, status: :unauthorized
    end
  end
end
