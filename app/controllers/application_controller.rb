class ApplicationController < ActionController::API
  include Authenticatable
  include ApiErrors
end
