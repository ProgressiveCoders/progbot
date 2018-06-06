
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def new_session_path(scope)
    user_session_path
  end

  protected
  def after_sign_in_path_for(resource)
    if resource.valid?
      if !resource.optin
        users_registration_path
      else
        welcome_dashboard_path
      end
    else
      edit_user_path(resource)
    end
  end
end
