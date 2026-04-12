# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :owner, class_name: "User", inverse_of: :projects

  has_many :tasks, dependent: :destroy

  validates :name, presence: true
end
