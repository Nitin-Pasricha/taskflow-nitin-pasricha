# frozen_string_literal: true

# TaskFlow validation shape: { "error": "validation failed", "fields": { ... } }
module ApiErrors
  extend ActiveSupport::Concern

  private

  def render_not_found
    render json: { error: "not found" }, status: :not_found
  end

  def render_forbidden
    render json: { error: "forbidden" }, status: :forbidden
  end

  def render_validation_failed(record)
    fields = {}
    record.errors.each do |error|
      fields[error.attribute.to_s] = validation_message_for(error)
    end
    render json: { error: "validation failed", fields: fields }, status: :bad_request
  end

  def validation_message_for(error)
    case error.type
    when :blank
      "is required"
    when :taken
      "is already taken"
    else
      error.message
    end
  end
end
