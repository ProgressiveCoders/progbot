require 'pry'

class Dashboard::ProjectsController < Dashboard::BaseController
  inherit_resources
  include SlackHelpers
  
  def all
    @projects = Project.order("name ASC").includes(:stacks).where(:mission_aligned => true)
  end

  def create
    @project = Project.new(project_params)

    @project.get_ids_from_names(project_params[:tech_stack_names].split(", "), project_params[:non_tech_stack_names].split(", "), project_params[:needs_category_names].split(", "))

    if @project.valid?
      @project.save
      redirect_to edit_dashboard_project_path(@project)
    else
      render :edit
    end
  end
  
  def show
    @project = Project.find(params[:id])
  end

  def edit
    @channels = get_slack_channels
  end



  def update

    if params[:slack_channel]
      
      resource.get_slack_channel_id(get_slack_channels, params[:slack_channel])
    end

    resource.get_ids_from_names(project_params[:tech_stack_names].split(", "), project_params[:non_tech_stack_names].split(", "), project_params[:needs_category_names].split(", "))

    if resource.update(project_params)
      redirect_to edit_dashboard_project_path(@project)
    else
      render :edit
    end

  end

  private

  def get_slack_channels
    channels = Rails.cache.fetch('get_slack_channels', expires_in: 12.hours) do
      client.channels_list.channels
    end

  end

  
  def begin_of_association_chain
    current_user
  end

  def project_params
    params.require(:project).permit(:name, :description, :website, :slack_channel, :active_contributors, :project_created, :mission_accomplished, :needs_pain_points_narrative, :org_structure, :project_mgmt_url, :summary_test, :repository, :slack_channel_url, :software_license_url, :values_screening, :working_doc, :full_release_features, :attachments, :tech_stack_names, :needs_category_names, :non_tech_stack_names, business_models: [],  legal_structures: [], oss_license_types: [], progcode_coordinator_ids: [], project_applications: [],  lead_ids: [], status: [], master_channel_list: [])
  end
end

