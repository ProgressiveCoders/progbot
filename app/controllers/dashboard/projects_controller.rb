require 'pry'

class Dashboard::ProjectsController < Dashboard::BaseController
  inherit_resources
  
  def all
    @projects = Project.order("name ASC").includes(:stacks).where(:mission_aligned => true)
  end

  def create
    @project = Project.new(project_params)
    tech_names = project_params[:tech_stack_names].split(", ")
    non_tech_names = project_params[:non_tech_stack_names].split(", ")
    needs_category_names = project_params[:needs_category_names].split(", ")
    @project.tech_stack = Skill.where(:name => tech_names)
    @project.non_tech_stack = Skill.where(:name => non_tech_names)
    @project.needs_categories = Skill.where(:name => needs_category_names)
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



  def update
    if resource.update(project_params)
      redirect_to edit_dashboard_project_path(@project)
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

