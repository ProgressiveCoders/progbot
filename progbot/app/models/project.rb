class Project < ApplicationRecord
  belongs_to :user, foreign_key: "lead"
  has_and_belongs_to_many :user, through: "volunteers"
  has_and_belongs_to_many :skills, through: "required_skills"
end
