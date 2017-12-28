class User < ApplicationRecord
  belongs_to :referer, class_name: "User"
  has_and_belongs_to_many :tech_skills, class_name: "Skill"
  has_and_belongs_to_many :non_tech_skills, class_name: "Skill"
end
