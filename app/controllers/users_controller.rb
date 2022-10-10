class UsersController < ApplicationController
  inherit_resources
  before_action :set_skills


  # def create
  #   if User.find_by(email: params["user"]["email"]) && params["user"]["email"] != ''
  #     @user = User.find_by(email: params["user"]["email"])
  #     if !@user.is_approved
  #       @user.update(user_params)
  #       EmailNotifierMailer.with(user: @user).new_user_signed_up_again.deliver_later
  #     else
  #       EmailNotifierMailer.with(user: @user).existing_user_signed_up.deliver_later
  #     end
  #     redirect_to users_new_confirmation_path
  #   else
  #     create! do |success, failure|
  #       success.html {
  #         if @user.is_approved
  #           redirect_to user_slack_omniauth_authorize_path
  #         else
  #           EmailNotifierMailer.with(user: @user).new_user_signed_up.deliver_later
  #           EmailNotifierMailer.with(user: @user).new_user_admin_notification.deliver_later
  #           redirect_to users_new_confirmation_path
  #         end
  #       }
  #     end

  #   end
  # end

  # def new
  #   if !@user
  #     @user = User.new(is_approved: false)
  #   end

  # end

  def confirmation

  end

  def registration
    if current_user
      if !current_user.is_approved
        redirect_to users_new_confirmation_path
      elsif current_user.is_approved && current_user.optin
        redirect_to dashboard_base_index_path
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
