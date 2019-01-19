class Project < ApplicationRecord
  include ProjectConstants

  attr_accessor :tech_stack_names, :non_tech_stack_names, :needs_category_names

  has_and_belongs_to_many :needs_categories, class_name: "Skill", join_table: "needs_categories"
  
  has_and_belongs_to_many :stacks, class_name: "Skill", join_table: "projects_skills"
  
  has_and_belongs_to_many :tech_stack, -> { where tech: true }, class_name: "Skill", join_table: "projects_skills"
  has_and_belongs_to_many :non_tech_stack, -> { where tech: !true }, class_name: "Skill", join_table: "projects_skills"

  has_and_belongs_to_many :volunteers, class_name: "User", join_table: "projects_volunteers"

  validates_presence_of :name, :description, :tech_stack
  
  validates :legal_structures, :presence => true,:allow_blank => false

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

  def tech_tack_names=(stack_names)
    self.tech_stack_ids = Skill.where(name: stack_names.split(", ")).pluck(:id)
  end

  def tech_stack_names
    unless self.tech_stack.blank?
      self.tech_stack.map { |stack| stack.name }
    end
  end

  # def non_tech_stack_names
  #   self.non_tech_stack.pluck(:name)
  # end

  # def needs_category_names
  #   self.needs_categories.pluck(:name)
  # end

  def flagged?
    !self.import_errors.blank?
  end

end
