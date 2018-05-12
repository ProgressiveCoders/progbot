require 'pry'

class WelcomeController < ApplicationController

  def home
    if session[:uid] != nil
      redirect_to welcome_dashboard_path
    end
  end

  def dashboard
    if session[:uid] != nil
      @user = User.find_by(id: session[:uid])
    else
      redirect_to root_path
    end
  end


end
