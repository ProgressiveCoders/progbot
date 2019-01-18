class Dashboard::ProjectsController < Dashboard::BaseController
  inherit_resources

  def show

  end

  def create
    create! do |success, failure|
      success.html {
        redirect_to dashboard_project_path(@project)
      }
      failure.html {
        render :edit
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
    params.require(:project).permit(:name, :status, :description, :website, :slack_channel, :active_contributors, :project_created, :master_channel_list, :mission_accomplished, :needs_pain_points_narrative, :org_structure, :project_mgmt_url, :summary_test, :repository, :slack_channel_url, :software_license_url, :values_screening, :working_doc, :full_release_features, attachments: [], business_models: [],  legal_structures: [], oss_license_types: [], progcode_coordinators: [], project_applications: [], project_lead_slack_ids: [], team_member_ids: [], lead_ids: [], needs_categories: [])
  end
end

