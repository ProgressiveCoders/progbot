class Project < ApplicationRecord
  include ProjectConstants

  attr_accessor :tech_skill_names, :non_tech_skill_names

  has_and_belongs_to_many :needs_categories, class_name: "Skill", join_table: "needs_categories"
  
  has_and_belongs_to_many :tech_skills, -> { where tech: true }, class_name: "Skill", join_table: "projects_skills"
  has_and_belongs_to_many :non_tech_skills, -> { where tech: false }, class_name: "Skill", join_table: "projects_skills"

  has_and_belongs_to_many :volunteers, class_name: "User", join_table: "projects_volunteers"

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

  def tech_skill_names=(skill_names)
    self.tech_skill_ids = Skill.where(name: skill_names.split(", ")).pluck(:id)
  end

  def non_tech_skill_names=(skill_names)
    self.non_tech_skill_ids = Skill.where(name: skill_names.split(", ")).pluck(:id)
  end

  

end
