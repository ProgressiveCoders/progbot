class RemoveNonArrayedColumns < ActiveRecord::Migration[5.1]
  def change
    remove_column :projects, :business_model
    remove_column :projects, :legal_structure
    remove_column :projects, :oss_license_type
    remove_column :projects, :progcode_coordinator
    remove_column :projects, :project_applications
    remove_column :projects, :project_lead_slack_id
    remove_column :projects, :team_member_ids
  end
end
