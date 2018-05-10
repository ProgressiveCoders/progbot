require 'pry'

class WelcomeController < ApplicationController

  def home
    binding.pry
    if session[:user_id]
      redirect_to welcome_dashboard_path
    end
  end

  def dashboard
    binding.pry
  end


end
