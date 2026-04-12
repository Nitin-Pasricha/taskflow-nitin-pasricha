# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :owner, class_name: "User", inverse_of: :projects

  validates :name, presence: true
end
