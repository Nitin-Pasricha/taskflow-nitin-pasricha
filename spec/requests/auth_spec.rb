# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Auth", type: :request do
  describe "POST /auth/register" do
    it "returns 201 and a token" do
      post "/auth/register",
        params: { name: "New", email: "newuser@example.com", password: "somepassword1" },
        as: :json

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["token"]).to be_present
      expect(body.dig("user", "email")).to eq("newuser@example.com")
    end
  end

  describe "POST /auth/login" do
    let(:password) { "correct-horse-battery-staple" }
    let(:user) do
      User.create!(
        name: "Login User",
        email: "login@example.com",
        password: password
      )
    end

    before { user }

    it "returns 200 with valid credentials" do
      post "/auth/login",
        params: { email: user.email, password: password },
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["token"]).to be_present
    end

    it "returns 401 with bad password" do
      post "/auth/login",
        params: { email: user.email, password: "wrong" },
        as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
