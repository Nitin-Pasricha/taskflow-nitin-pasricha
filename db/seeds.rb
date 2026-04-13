# frozen_string_literal: true

# Idempotent: safe to run multiple times (`bin/rails db:seed`).
# Default login for the seeded user: email below, password from SEED_USER_PASSWORD or "password123".

SEED_EMAIL = "seed@example.com"
SEED_PASSWORD = ENV.fetch("SEED_USER_PASSWORD", "password123")

user = User.find_or_initialize_by(email: User.normalize_email(SEED_EMAIL))
user.name = "Seed User"
user.password = SEED_PASSWORD
user.save!

project = user.projects.where(name: "TaskFlow Demo").first_or_create!(
  description: "Seeded project for local development and reviewers"
)

[
  { title: "Review API documentation", status: :todo, priority: :low },
  { title: "Implement dashboard filters", status: :in_progress, priority: :medium },
  { title: "Ship TaskFlow submission", status: :done, priority: :high }
].each do |attrs|
  task = project.tasks.find_or_initialize_by(title: attrs[:title])
  task.assign_attributes(
    creator: user,
    description: nil,
    status: attrs[:status],
    priority: attrs[:priority],
    assignee_id: nil
  )
  task.save!
end

puts "Seeded #{SEED_EMAIL} / project '#{project.name}' / #{project.tasks.count} tasks"
