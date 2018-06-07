
class UsersController < ApplicationController
  inherit_resources
  before_action :set_skills


  def create
    create! do |success, failure|
      success.html {
        if @user.is_approved
          redirect_to user_slack_omniauth_authorize_path
        else
          redirect_to users_new_confirmation_path
        end
      }
      # create separate workflow for approved member and non-approved member (see project overview). if validation passes the non-approved member is taken to a page where they are told to wait until they receive an email invitation to slack. approved members are redirected to a registration path where they check their info one last time and "opt in" to progbot

    end
  end

  def new
    if !@user
      @user = User.new(is_approved: false)
    end
  end

  def edit
    if !current_user
      redirect_to new_user_path
    end
  end

  def update
    if current_user.update!(user_params)
      if current_user.optin?
        redirect_to welcome_dashboard_path
      else
        redirect_to users_registration_path
      end
    else
      redirect_to edit_users_path
    end
  end

  def confirmation

  end

  def registration
    if current_user
      if !current_user.is_approved
        redirect_to users_new_confirmation_path
      elsif current_user.is_approved && current_user.optin
        redirect_to welcome_dashboard_path
      end
    else
      redirect_to root_path
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :edit, :name, :anonymous, :email, :join_reason,
      :overview, :location, :tech_skill_names, :non_tech_skill_names,
      :optin, :phone, :slack_username, :read_code_of_conduct,
      :verification_urls, :hear_about_us, :is_approved
    )
  end


end
