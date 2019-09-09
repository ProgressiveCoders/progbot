class Skill < ApplicationRecord

  has_and_belongs_to_many :project_needs, class_name: "Project", join_table: "needs_categories"

  has_and_belongs_to_many :users

  has_and_belongs_to_many :projects, join_table: "projects_skills"

  scope :tech_skills, -> () { where(tech: true).order("name ASC") }
  scope :non_tech_skills, -> () { where(tech: !true).order("name ASC") }
  scope :match_skill, -> (str) { where("lower(name) = lower(?)", str_or_arr) }
  scope :match_skills, -> (arr) { where("lower(name) IN (?)", arr.map(&:downcase)) }

  scope :simple_search,   -> (q) do
    q = "%#{q}%"
    where("name ILIKE ?", q).order("created_at ASC")
  end

  audited

end
