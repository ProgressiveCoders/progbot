class User < ApplicationRecord
  belongs_to :user, foreign_key: "referer"
  has_and_belongs_to_many :skills, through: "tech_skills"
  has_and_belongs_to_many :skills, through: "other_skills"
end
