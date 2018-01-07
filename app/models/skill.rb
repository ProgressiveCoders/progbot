class Skill < ApplicationRecord
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :users
  has_and_belongs_to_many :skill_categories, join_table: "skills_categories_matching"
end
