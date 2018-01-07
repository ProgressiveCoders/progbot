class AddSkillCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :skill_categories do |t|
      t.string :name
      t.bool :tech_stack
    end

    create_table :skills_categories_matching do |t|
      t.belongs_to :skill, index: true
      t.belongs_to :skill_categories, index: true
    end
  end
end
