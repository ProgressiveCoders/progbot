class AddNeedsCategoriesTable < ActiveRecord::Migration[5.1]
  def change
    create_table :needs_categories do |t|
      t.bigint :project_id
      t.bigint :skill_id
    end
  end
end
