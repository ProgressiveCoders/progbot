

class WelcomeController < ApplicationController

  def home
    if user_signed_in?
      redirect_to welcome_dashboard_path
    end

  end

  def dashboard
    if !user_signed_in?
      redirect_to welcome_home_path
    end
  end


end
