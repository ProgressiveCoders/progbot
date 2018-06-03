

class WelcomeController < ApplicationController

  def home


  end

  def dashboard
    if !current_user
      redirect_to welcome_home_path
    end
  end


end
