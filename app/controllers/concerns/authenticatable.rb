# frozen_string_literal: true

# Decode +Authorization: Bearer+ and expose +current_user+ / +authenticate_user!+.
# Use +before_action :authenticate_user!+ on controllers that require a logged-in user.
module Authenticatable
  extend ActiveSupport::Concern

  def authenticate_user!
    return if current_user

    render json: { error: "unauthorized" }, status: :unauthorized
  end

  def current_user
    return @current_user if instance_variable_defined?(:@current_user)

    payload = JsonWebToken.decode(bearer_token)
    @current_user = if payload.blank? || payload["user_id"].blank?
                      nil
                    else
                      User.find_by(id: payload["user_id"])
                    end
  end

  def bearer_token
    header = request.headers["Authorization"].to_s
    return if header.blank?

    header.strip.delete_prefix("Bearer ").presence
  end
end
