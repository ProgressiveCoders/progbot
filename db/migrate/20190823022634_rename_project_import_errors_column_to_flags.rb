class RenameProjectImportErrorsColumnToFlags < ActiveRecord::Migration[5.1]
  def change
    rename_column :projects, :import_errors, :flags
  end
end
