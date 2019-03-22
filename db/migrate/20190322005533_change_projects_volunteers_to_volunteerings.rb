class ChangeProjectsVolunteersToVolunteerings < ActiveRecord::Migration[5.1]
  def change
    rename_table :projects_volunteers, :volunteerings
  end
end
