class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  audited
  
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
end
