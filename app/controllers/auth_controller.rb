# frozen_string_literal: true

class AuthController < ApplicationController
  def register
    user = User.new(register_params)
    if user.save
      render json: auth_response(user), status: :created
    else
      render_validation_failed(user)
    end
  end

  def login
    user = User.find_by(email: User.normalize_email(login_params[:email]))
    if user&.authenticate(login_params[:password])
      render json: auth_response(user), status: :ok
    else
      render json: { error: "unauthorized" }, status: :unauthorized
    end
  end

  private

  def register_params
    params.permit(:name, :email, :password)
  end

  def login_params
    params.permit(:email, :password)
  end

  def auth_response(user)
    {
      token: JsonWebToken.encode(user),
      user: user_response(user)
    }
  end

  def user_response(user)
    {
      id: user.id,
      name: user.name,
      email: user.email
    }
  end
end
