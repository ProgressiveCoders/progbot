class UserSkills < ActiveRecord::Migration[5.1]
  def change
    create_table :users_skills, id: false do |t|
        t.belongs_to :user, index: true
        t.belongs_to :skill, index: true
    end
  end
end
