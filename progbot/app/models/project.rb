class Project < ApplicationRecord
  belongs_to :lead, class_name: "User"
  has_and_belongs_to_many :volunteers, class_name: "User"
  has_and_belongs_to_many :skills
end
