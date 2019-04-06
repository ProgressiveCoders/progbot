class Dashboard::SkillsController < Dashboard::BaseController
  inherit_resources
  before_action :authenticate_user!

  
end
