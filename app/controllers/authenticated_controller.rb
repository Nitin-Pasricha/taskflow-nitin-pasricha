# frozen_string_literal: true

# API controllers that require a valid JWT. Public routes stay on ApplicationController
# (e.g. AuthController).
class AuthenticatedController < ApplicationController
  before_action :authenticate_user!
end
