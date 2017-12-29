class ProjectSkills < ActiveRecord::Migration[5.1]
  def change
    create_table :projects_skills, id: false do |t|
        t.belongs_to :project, index: true
        t.belongs_to :skill, index: true
    end
  end
end
