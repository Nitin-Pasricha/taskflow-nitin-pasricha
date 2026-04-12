# frozen_string_literal: true

# HS256 access tokens for TaskFlow: 24h expiry, +user_id+ and +email+ in payload (spec).
class JsonWebToken
  ALGORITHM = "HS256"
  EXPIRY = 24.hours

  class << self
    def encode(user)
      payload = {
        "user_id" => user.id,
        "email" => user.email,
        "exp" => EXPIRY.from_now.to_i
      }
      JWT.encode(payload, secret, ALGORITHM)
    end

    # Returns decoded payload hash (string keys) or +nil+ if missing/invalid/expired.
    def decode(token)
      return if token.blank?

      decoded = JWT.decode(token, secret, true, { algorithm: ALGORITHM })
      decoded.first
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end

    def secret
      ENV.fetch("JWT_SECRET")
    end
  end
end
