class AddArrayedColumns < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :attachments, :text, array: true, default: []
    add_column :projects, :business_models, :string, array: true, default: []
    add_column :projects, :legal_structures, :string, array: true, default: []
    add_column :projects, :oss_license_types, :string, array: true, default: []
    add_column :projects, :progcode_coordinator_ids, :integer, array: true, default: []
    add_column :projects, :project_applications, :string, array: true, default: []
    add_column :projects, :project_lead_slack_ids, :string, array: true, default: []
    add_column :projects, :team_member_ids, :string, array: true, default: []
  end
end
