# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :project
  belongs_to :assignee, class_name: "User", inverse_of: :assigned_tasks, optional: true
  belongs_to :creator, class_name: "User", inverse_of: :created_tasks

  enum :status, { todo: "todo", in_progress: "in_progress", done: "done" }, default: :todo, validate: true
  enum :priority, { low: "low", medium: "medium", high: "high" }, default: :low, validate: true

  validates :title, presence: true
end
