class User < ApplicationRecord
  attr_accessor :tech_skill_names, :non_tech_skill_names
  belongs_to :referer, class_name: "User", optional: true
  has_and_belongs_to_many :tech_skills, -> { where tech: true }, class_name: "Skill"
  has_and_belongs_to_many :non_tech_skills, -> { where tech: false }, class_name: "Skill"
  
  validates_presence_of :name, :email
  
  
  def tech_skill_names=(skill_names)
    self.tech_skill_ids = Skill.where(name: skill_names.split(", ")).pluck(:id)
  end
  
  def non_tech_skill_names=(skill_names)
    self.non_tech_skill_ids = Skill.where(name: skill_names.split(", ")).pluck(:id)
  end
end
