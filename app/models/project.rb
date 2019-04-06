class Project < ApplicationRecord
  include ProjectConstants

  attr_accessor :tech_stack_names, :non_tech_stack_names, :needs_category_names

  has_and_belongs_to_many :needs_categories, class_name: "Skill", join_table: "needs_categories"
  
  has_and_belongs_to_many :stacks, class_name: "Skill", join_table: "projects_skills"
  
  has_and_belongs_to_many :tech_stack, -> { where tech: true }, class_name: "Skill", join_table: "projects_skills"
  has_and_belongs_to_many :non_tech_stack, -> { where tech: !true }, class_name: "Skill", join_table: "projects_skills"

  has_many :volunteerings
  has_many :active_volunteerings,  -> { where state: 'active' }, class_name: 'Volunteering'
  has_many :volunteers, through: :active_volunteerings, source: 'user'

  validates_presence_of :name, :description, :tech_stack, :tech_stack_names
  
  validates :legal_structures, :presence => true, :allow_blank => false, :if => :new_record?

  after_save :remove_blank_values
  audited
  has_associated_audits
  
  def leads
    lead_ids.blank? ? [] : User.where(:id => self.lead_ids)
  end

  def progcode_coordinators
    progcode_coordinator_ids.blank? ? [] : User.where(:id => self.progcode_coordinator_ids)
  end
  
  def leads=(users)
    self.lead_ids = users.map(&:id)
  end

  def tech_tack_names=(stack_names)
    self.tech_stack_ids = Skill.where(name: stack_names.split(", ")).pluck(:id)
  end

  def tech_stack_names
    if self.tech_stack.blank?
      []
    else
      self.tech_stack.map { |stack| stack.name }
    end
  end

  def non_tech_stack_names=(stack_names)
    self.non_tech_stack_ids = Skill.where(name: stack_names.split(", ")).pluck(:id)
  end

  def non_tech_stack_names
    if self.tech_stack.blank?
      []
    else
      self.non_tech_stack.map { |stack| stack.name }
    end
  end

  def needs_category_names=(category_names)
    self.needs_category_ids = Skill.where(name: category_names.split(", ")).pluck(:id)
  end

  def needs_category_names
    if self.needs_categories.blank?
      []
    else
      self.needs_categories.map { |need| need.name }
    end
  end

  def flagged?
    !self.import_errors.blank?
  end

  def remove_blank_values
    self.status  = self.status.reject(&:empty?)
    self.legal_structures = self.legal_structures.reject(&:empty?)
  end

end
