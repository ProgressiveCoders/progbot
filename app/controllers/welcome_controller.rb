require 'pry'

class WelcomeController < ApplicationController

  def home
    if session[:uid]
      redirect_to welcome_dashboard_path
    end
  end

  def dashboard
    binding.pry
    if session[:uid]
      @user = User.find_by(slack_userid: session[:uid])
    else
      redirect_to root_path
    end
  end


end
