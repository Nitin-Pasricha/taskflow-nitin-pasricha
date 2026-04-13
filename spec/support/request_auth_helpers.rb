# frozen_string_literal: true

module RequestAuthHelpers
  def auth_headers_for(user)
    token = JsonWebToken.encode(user)
    { "Authorization" => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include RequestAuthHelpers, type: :request
end
