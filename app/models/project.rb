class Project < ApplicationRecord
  include ProjectConstants

  has_and_belongs_to_many :volunteers, class_name: "User", join_table: "projects_volunteers"
  has_and_belongs_to_many :skills

  audited

  audited associated_with: :user
  audited associated_with: :skills
  has_associated_audits
  
  def leads
    lead_ids.blank? ? [] : User.where(:id => self.lead_ids)
  end
  
  def leads=(users)
    self.lead_ids = users.map(&:id)
  end

end
