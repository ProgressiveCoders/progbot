class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :status
      t.text :description
      t.references :lead, foreign_key: false
      t.string :website
      t.string :slack_channel

      t.timestamps
    end
  end
end
