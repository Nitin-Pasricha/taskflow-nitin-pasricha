# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :projects, foreign_key: :owner_id, inverse_of: :owner, dependent: :restrict_with_exception
  has_many :assigned_tasks, class_name: "Task", foreign_key: :assignee_id, inverse_of: :assignee, dependent: :restrict_with_exception
  has_many :created_tasks, class_name: "Task", foreign_key: :creator_id, inverse_of: :creator, dependent: :restrict_with_exception

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
