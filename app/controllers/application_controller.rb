class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_skills

  def new_session_path(scope)
    user_session_path
  end

  protected
  def set_skills
    @tech_skills = Skill.tech_skills
    @non_tech_skills = Skill.non_tech_skills
    @all_skills = Skill.all
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(AdminUser)
      admin_dashboard_path
    # elsif resource.valid?
    else
      if !resource.optin
        users_registration_path
      else
        dashboard_base_index_path
      end
    # else
    #   edit_dashboard_user_path
    end
  end
end
