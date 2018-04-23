class User < ApplicationRecord
  belongs_to :referer, class_name: "User", optional: true
  has_and_belongs_to_many :skills
  
  validates_presence_of :name, :email
  
end
