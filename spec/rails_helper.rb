# frozen_string_literal: true

# Always use test for RSpec — do not inherit RAILS_ENV=production from shell or Docker workflows.
ENV["RAILS_ENV"] = "test"
ENV["JWT_SECRET"] ||= "test_jwt_secret_minimum_length_for_hs256"

require "spec_helper"
require_relative "../config/environment"
abort("Rails is running in production!") if Rails.env.production?

require "rspec/rails"

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

Rails.root.glob("spec/support/**/*.rb").sort.each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
