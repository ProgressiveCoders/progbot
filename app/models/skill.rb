class Skill < ApplicationRecord
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :users

  scope :tech_skills, -> () { where(tech: true).order("name ASC") }
  scope :non_tech_skills, -> () { where(tech: false).order("name ASC") }
  scope :match_skill, -> (str) { where("lower(name) = lower(?)", str_or_arr) }
  scope :match_skills, -> (arr) { where("lower(name) IN (?)", arr.map(&:downcase)) }

  audited

  audited associated_with: :project
  audited associated_with: :user
  has_associated_audits

end
