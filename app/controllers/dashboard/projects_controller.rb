class Dashboard::ProjectsController < Dashboard::BaseController
  inherit_resources
  before_action :set_skills

  def show

  end

  def create
    create! do |success, failure|
      success.html {
        redirect_to dashboard_project_path(@project)
      }
    end
  end

  def new
    @project = Project.new
  end

  private
  
  def begin_of_association_chain
    current_user
  end

  def project_params
    params.require(:project).permit(:name, :status, :description, :website, :slack_channel, :active_contributors, attachments: [], business_models: [], :full_release_features, legal_structures: [], :master_channel_list, :mission_accomplished, :needs_pain_points_narrative, :org_structure, oss_license_types: [], progcode_coordinators: [], project_applications: [], :project_mgmt_url, :summary_test, :repository, :slack_channel_url, :software_license_url, :values_screening, :working_doc, project_lead_slack_ids: [], team_member_ids: [], lead_ids: [], needs_categories: [], :project_created)
  end
end

