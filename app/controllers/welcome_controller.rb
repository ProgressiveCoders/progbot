class WelcomeController < ApplicationController
  before_action :authenticate_user!, except: [:home]
  
  def home
    if user_signed_in?
      redirect_to welcome_dashboard_path
    end
  end

  def dashboard
  end


end
