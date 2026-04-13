# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Projects", type: :request do
  include_context "with authenticated user"

  describe "GET /projects" do
    it "returns 401 without token" do
      get "/projects", as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "lists owned project" do
      project = current_user.projects.create!(name: "P1", description: "d")
      get "/projects", headers: auth_headers, as: :json

      expect(response).to have_http_status(:ok)
      ids = response.parsed_body["projects"].map { |p| p["id"] }
      expect(ids).to include(project.id)
    end
  end

  describe "GET /projects/:id" do
    it "returns 400 for malformed id" do
      get "/projects/not-a-uuid", headers: auth_headers, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body.dig("fields", "id")).to eq("is invalid")
    end
  end
end
