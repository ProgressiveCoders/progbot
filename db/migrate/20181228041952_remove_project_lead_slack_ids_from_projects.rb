class RemoveProjectLeadSlackIdsFromProjects < ActiveRecord::Migration[5.1]
  def change
    remove_column :projects, :project_lead_slack_ids
  end
end
