class Dashboard::ProjectsController < Dashboard::BaseController
  inherit_resources

  private
  
  def begin_of_association_chain
    current_user
  end

  def project_params
    params.require(:project).permit(:name, :status, :description, :website, :slack_channel, :active_contributors, :attachments, :business_model, :full_release_features, :legal_structure, :master_channel_list, :mission_accomplished, :needs_pain_points_narrative, :org_structure, :oss_license_type, :progcode_coordinator, :project_applications, :project_mgmt_url, :summary_test, :repository, :slack_channel_url, :software_license_url, :values_screening, :working_doc, :project_lead_slack_id, :team_member_ids, lead_ids: [], needs_categories: [])
  end
end

