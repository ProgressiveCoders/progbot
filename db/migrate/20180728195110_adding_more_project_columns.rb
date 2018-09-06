class AddingMoreProjectColumns < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :active_contributors, :string
    add_column :projects, :attachments, :text
    add_column :projects, :business_model, :string
    add_column :projects, :full_release_features, :text
    add_column :projects, :legal_structure, :string
    add_column :projects, :master_channel_list, :string
    add_column :projects, :mission_accomplished, :text
    add_column :projects, :needs_categories, :string, array: true
    add_column :projects, :needs_pain_points_narrative, :text
    add_column :projects, :org_structure, :string
    add_column :projects, :oss_license_type, :string
    add_column :projects, :progcode_coordinator, :string
    add_column :projects, :project_applications, :string
    add_column :projects, :project_created, :datetime
    add_column :projects, :project_mgmt_url, :string
    add_column :projects, :project_summary_text, :string
    add_column :projects, :repository, :string
    add_column :projects, :slack_channel_url, :string
    add_column :projects, :software_license_url, :string
    add_column :projects, :values_screening, :string
    add_column :projects, :working_doc, :string
    
    add_column :projects, :project_lead_slack_id, :string
    add_column :projects, :team_member_ids, :string
  end
end