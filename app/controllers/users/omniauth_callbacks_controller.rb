# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def slack
    auth = request.env['omniauth.auth']
    @user = User.find_by(email: auth['info']['email'])
    if @user
      if !@user.slack_userid || @user.slack_userid != auth['uid']
        @user.slack_userid = auth['uid']
        @user.slack_username = auth['info']['user']
      end
      if @user.save
        sign_in_and_redirect @user
      else
        redirect_to edit_users_path
      end
    else
      session['devise.preliminary_user'] = auth['info']
      redirect_to new_user_path
    end
  end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end