class UsersController < ApplicationController
  inherit_resources
  before_action :set_skills
  
  def create
    create! do |success, failure|
      success.html { redirect_to new_users_path }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to edit_users_path }
    end
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
      :verification_urls, :hear_about_us
    )
  end
end

