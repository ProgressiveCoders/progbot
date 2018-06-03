require 'pry'
class UsersController < ApplicationController
  inherit_resources
  before_action :set_skills

  def create
    create! do |success, failure|
      success.html {
        binding.pry
        if @user.is_approved
          redirect_to user_slack_omniauth_authorize_path
        else
          redirect_to confirmation_path
        end
      }
      # create separate workflow for approved member and non-approved member (see project overview). if validation passes the non-approved member is taken to a page where they are told to wait until they receive an email invitation to slack. approved members are redirected to a registration path where they check their info one last time and "opt in" to progbot

    end
  end

  def new
    if session['devise.preliminary_user']
      params = session['devise.preliminary_user']
      @user = User.new(name: params["name"], email: params["email"], slack_username: params["user"], slack_userid: params["user_id"], is_approved: true )
      if @user.slack_username == nil
        @user.slack_username = params[:name]
      end
    else
      @user = User.new(is_approved: false)
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to edit_users_path }
    end
  end

  def confirmation
    binding.pry
  end

  def registration

    binding.pry
    @user = User.find(session[:id])
    reset_session
    binding.pry
  end

  private

  def set_skills
    @tech_skills = Skill.tech_skills
    @non_tech_skills = Skill.non_tech_skills
  end

  def user_params
    params.require(:user).permit(
      :edit, :name, :anonymous, :email, :join_reason,
      :overview, :location, :tech_skill_names, :non_tech_skill_names,
      :optin, :phone, :slack_username, :read_code_of_conduct,
      :verification_urls, :hear_about_us, :is_approved
    )
  end


end
