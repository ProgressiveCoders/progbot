require 'pry'

class Dashboard::ProjectsController < Dashboard::BaseController
  inherit_resources

  def show

  end

  def create
    @project = Project.new(project_params)
    binding.pry
  end

  def new
    @project = Project.new
    binding.pry
  end

  private
  
  def begin_of_association_chain
    current_user
  end

  def project_params
    params.require(:project).permit(:name, :description, :website, :slack_channel, :active_contributors, :project_created, :mission_accomplished, :needs_pain_points_narrative, :org_structure, :project_mgmt_url, :summary_test, :repository, :slack_channel_url, :software_license_url, :values_screening, :working_doc, :full_release_features, :attachments, :tech_stack_names, :needs_category_names, :non_tech_stack_names, business_models: [],  legal_structures: [], oss_license_types: [], progcode_coordinator_ids: [], project_applications: [],  lead_ids: [], status: [], master_channel_list: [])
  end
end

