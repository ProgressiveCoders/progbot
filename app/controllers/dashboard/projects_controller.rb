class Dashboard::ProjectsController < Dashboard::BaseController
  inherit_resources

  private
  
  def begin_of_association_chain
    current_user
  end

  def project_params
    params.require(:project).permit()
  end
end

