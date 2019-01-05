class AdjustProjectSchema < ActiveRecord::Migration[5.1]
  def change
    remove_column :projects, :status
    add_column :projects, :status, :string, array: true, default: []
    rename_column :projects, :flagged, :import_errors
  end
end
