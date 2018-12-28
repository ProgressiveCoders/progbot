class RemoveProjectSummaryTextFromProjects < ActiveRecord::Migration[5.1]
  def change
    remove_column :projects, :project_summary_text
  end
end
