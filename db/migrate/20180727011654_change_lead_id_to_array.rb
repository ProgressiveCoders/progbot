class ChangeLeadIdToArray < ActiveRecord::Migration[5.1]
  def change
    change_column :projects, :lead_id, :integer, :array => true, default: [], using: "ARRAY[lead_id]::INTEGER[]"
    rename_column :projects, :lead_id, :lead_ids
  end
end