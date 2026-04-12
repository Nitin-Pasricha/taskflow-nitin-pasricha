# frozen_string_literal: true

# TaskFlow: JWT secret must never be committed; use ENV (see .env.example).
if Rails.env.production? && ENV["JWT_SECRET"].to_s.strip.empty?
  raise "JWT_SECRET must be set in the environment for production"
end
