# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :projects, foreign_key: :owner_id, inverse_of: :owner, dependent: :restrict_with_exception

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
