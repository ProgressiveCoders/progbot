
class Dashboard::ProjectsController < Dashboard::BaseController
  inherit_resources
  include SlackHelpers
  
  def all
    @projects = Project.order("name ASC").includes(:stacks).where(:mission_aligned => true)
  end

  def create
    @project = Project.new(project_params)
    @user = current_user

    @project.get_ids_from_names(project_params[:tech_stack_names].split(", "), project_params[:non_tech_stack_names].split(", "), project_params[:needs_category_names].split(", "))

    if @project.valid?
      @project.project_created = Time.current
      @project.save
      EmailNotifierMailer.with(user: @user, project: @project).new_project_confirmation.deliver_later
      EmailNotifierMailer.with({user: @user, project: @project}).new_project_admin_notification.deliver_later
      redirect_to edit_dashboard_project_path(@project)
    else
      render :edit
    end
  end
  
  def show

  end

  def edit
    @channels = SlackHelpers.get_slack_channels
    skills = resource.tech_stack.map{|s| s.name}.join(",")
    print skills
    
  end

  def update

    resource.assign_attributes(project_params)
    
    if params[:slack_channel]
      
      resource.get_slack_channel_id(params[:slack_channel])
    end

    resource.get_ids_from_names(project_params[:tech_stack_names].split(", "), project_params[:non_tech_stack_names].split(", "), project_params[:needs_category_names].split(", "))

    if resource.save
      redirect_to edit_dashboard_project_path(resource)
    else
      render :edit
    end

  end

  private

  
  def begin_of_association_chain
    current_user
  end

  def project_params
    params.require(:project).permit(:name, :description, :website, :slack_channel, :active_contributors, :project_created, :mission_accomplished, :needs_pain_points_narrative, :org_structure, :project_mgmt_url, :summary_test, :repository, :slack_channel_url, :software_license_url, :values_screening, :working_doc, :full_release_features, :attachments, :tech_stack_names, :needs_category_names, :non_tech_stack_names, business_models: [],  legal_structures: [], oss_license_types: [], progcode_coordinator_ids: [], project_applications: [],  lead_ids: [], status: [], master_channel_list: [])
  end
end

