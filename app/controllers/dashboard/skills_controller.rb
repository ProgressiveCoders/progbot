class Dashboard::SkillsController < Dashboard::BaseController
  inherit_resources
  before_action :authenticate_user!

  def show
    @projects_having = resource.projects.where(:mission_aligned => true)
    @projects_needing = resource.project_needs.where(:mission_aligned => true)
    @users_having = resource.users.where(:optin => true)
  end

  
end
