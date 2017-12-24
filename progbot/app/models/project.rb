class Project < ApplicationRecord
  belongs_to :lead, class_name: "User"
  has_and_belongs_to_many :users, join_table: :projects_volunteers
  has_and_belongs_to_many :skills
end
