class SkillCategory < ApplicationRecord
  has_and_belongs_to_many :skills, join_table: "skills_categories_matching"
end
