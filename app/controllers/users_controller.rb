class UsersController < ApplicationController
  inherit_resources
  before_action :set_skills


  def create
    if User.find_by(email: params["user"]["email"]) && params["user"]["email"] != ''
      @user = User.find_by(email: params["user"]["email"])
      if !@user.is_approved
        @user.update(user_params)
      end
      redirect_to user_path(@user)
    else
      create! do |success, failure|
        success.html {
          if @user.is_approved
            redirect_to user_slack_omniauth_authorize_path
          else
            redirect_to users_new_confirmation_path
          end
        }
      end

    end
  end

  def show
    @user = User.find(params[:id])
  end

  def existing
    @user = User.find_by(email: params["user"["email"]])
  end

  def new
    if !@user
      @user = User.new(is_approved: false)
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
      :verification_urls, :hear_about_us, :is_approved, :gender_pronouns, :additional_info
    )
  end


end
