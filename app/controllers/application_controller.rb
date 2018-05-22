class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def new_session_path(scope)
    user_session_path
  end

  protected
    def after_sign_in_path_for(resource)
      welcome_dashboard_path
    end
end
