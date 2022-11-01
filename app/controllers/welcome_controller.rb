class WelcomeController < ApplicationController
  before_action :authenticate_user!, except: [:home]

  def home
    byebug
    if user_signed_in?
      redirect_to dashboard_base_index_path
    end
  end

  # def dashboard
  #   if user_signed_in?
  #     # if !current_user.valid?
  #     #   redirect_to edit_user_path(current_user)
  #     # end
  #   else
  #     redirect_to welcome_home_path
  #   end
  # end


end
