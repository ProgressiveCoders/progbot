class ProjectVolunteers < ActiveRecord::Migration[5.1]
  def change
    create_table :projects_volunteers, id: false do |t|
      t.belongs_to :project, index: true
      t.belongs_to :user, index: true
    end
  end
end
