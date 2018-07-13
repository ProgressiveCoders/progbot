class Project < ApplicationRecord
  belongs_to :lead, class_name: "User"
  has_and_belongs_to_many :volunteers, class_name: "User", join_table: "projects_volunteers"
  has_and_belongs_to_many :skills

  audited

  audited associated_with: :user
  audited associated_with: :skills
  has_associated_audits

end
