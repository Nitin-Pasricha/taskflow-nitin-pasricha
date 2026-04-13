# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tasks", type: :request do
  include_context "with authenticated user"

  let(:project) { current_user.projects.create!(name: "P1", description: nil) }

  describe "nested under project" do
    it "creates a task" do
      post "/projects/#{project.id}/tasks",
        headers: auth_headers,
        params: { title: "T1", status: "todo", priority: "low" },
        as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["title"]).to eq("T1")
    end

    it "rejects invalid assignee filter on index" do
      get "/projects/#{project.id}/tasks?assignee=bad",
        headers: auth_headers,
        as: :json

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "PATCH /tasks/:id" do
    it "updates a task" do
      post "/projects/#{project.id}/tasks",
        headers: auth_headers,
        params: { title: "T1", status: "todo", priority: "low" },
        as: :json

      task_id = response.parsed_body["id"]

      patch "/tasks/#{task_id}",
        headers: auth_headers,
        params: { title: "T1 updated", status: "in_progress" },
        as: :json

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["title"]).to eq("T1 updated")
      expect(body["status"]).to eq("in_progress")
    end
  end

  describe "DELETE /tasks/:id" do
    it "allows creator to destroy" do
      post "/projects/#{project.id}/tasks",
        headers: auth_headers,
        params: { title: "To delete" },
        as: :json

      task_id = response.parsed_body["id"]

      delete "/tasks/#{task_id}", headers: auth_headers, as: :json
      expect(response).to have_http_status(:no_content)
    end
  end
end
