class ChangeNeedsCategoriesToIntegerInProjects < ActiveRecord::Migration[5.1]
  def change
    remove_column :projects, :needs_categories
  end
end
