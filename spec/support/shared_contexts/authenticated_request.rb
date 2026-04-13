# frozen_string_literal: true

RSpec.shared_context "with authenticated user" do
  let(:password) { "correct-horse-battery-staple" }
  let(:current_user) do
    User.create!(
      name: "Test User",
      email: "tester@example.com",
      password: password
    )
  end
  let(:auth_headers) { auth_headers_for(current_user) }
end
