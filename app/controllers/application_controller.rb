class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def new_session_path(scope)
    user_session_path
  end

  protected
  def set_skills
    @tech_skills = Skill.tech_skills
    @non_tech_skills = Skill.non_tech_skills
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(AdminUser)
      admin_root_path
    else
      if resource.valid?
        if !resource.optin
          users_registration_path
        else
          dashboard_base_index_path
        end
      else
        edit_dashboard_user_path
      end
    end
  end

end
