class AddAirtableIdsToProjectsAndUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :airtable_id, :string
    add_column :users, :airtable_id, :string
    add_index :projects, :airtable_id, unique: true
    add_index :users, :airtable_id, unique: true
  end
end
