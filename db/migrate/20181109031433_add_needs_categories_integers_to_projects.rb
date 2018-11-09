class AddNeedsCategoriesIntegersToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :needs_categories, :integer, array: true, default: []
  end
end
