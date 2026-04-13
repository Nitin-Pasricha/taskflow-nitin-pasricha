# frozen_string_literal: true

module FilterValidation
  extend ActiveSupport::Concern

  UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

  private

  def valid_uuid?(value)
    value.to_s.match?(UUID_REGEX)
  end

  def render_invalid_filter(field, message = "is invalid")
    render json: { error: "validation failed", fields: { field.to_s => message } }, status: :bad_request
  end

  # Path/query UUIDs: return false after render so callers can `return unless uuid_path_param_valid?(...)`.
  def uuid_path_param_valid?(value, field)
    return true if value.present? && valid_uuid?(value)

    render_invalid_filter(field)
    false
  end
end
