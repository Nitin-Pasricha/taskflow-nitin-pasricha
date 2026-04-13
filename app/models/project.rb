# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :owner, class_name: "User", inverse_of: :projects

  has_many :tasks, dependent: :destroy

  validates :name, presence: true

  scope :accessible_to, lambda { |user|
    task_project_ids = Task.where(assignee_id: user.id).or(Task.where(creator_id: user.id)).select(:project_id)
    where(owner_id: user.id).or(where(id: task_project_ids))
  }

  def accessible_to?(user)
    owner_id == user.id || tasks.exists?(["assignee_id = ? OR creator_id = ?", user.id, user.id])
  end
end
