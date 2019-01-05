class Project < ApplicationRecord
  include ProjectConstants

  has_and_belongs_to_many :needs_categories, class_name: "Skill", join_table: "needs_categories"
  
  has_and_belongs_to_many :skills, class_name: "Skill", join_table: "projects_skills"
  
  has_and_belongs_to_many :tech_stack, -> { where tech: true }, class_name: "Skill", join_table: "projects_skills"
  has_and_belongs_to_many :non_tech_stack, -> { where tech: !true }, class_name: "Skill", join_table: "projects_skills"

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

  def tech_stack_names
    self.tech_stack.pluck(:name)
  end

  def non_tech_stack_names
    self.non_tech_stack.pluck(:name)
  end

  def needs_category_names
    self.needs_categories.pluck(:name)
  end

  def flagged?
    !self.import_errors.blank?
  end

end
