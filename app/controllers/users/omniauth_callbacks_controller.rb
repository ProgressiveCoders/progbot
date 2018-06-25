# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController


  def slack
    auth = request.env['omniauth.auth']
    user_info = auth['extra']['raw_info']['user_info']['user']
    Rails.logger.info "SLACKK OMNIAUTH\n" + auth.inspect
    # check to make sure team id is correct
    @user = User.find_by(email: user_info['profile']['email']) || User.find_by(slack_userid: user_info['id'])
    if @user
      if !@user.slack_userid || @user.slack_userid != user_info['id']
        @user.slack_userid = user_info['id']
        @user.slack_username = user_info['name']
        @user.save
      end
      if !@user.email != user_info['profile']['email']
        @user.email = user_info['profile']['email']
      end
      sign_in_and_redirect @user
    else
      @user = User.new(is_approved: true, email: user_info['profile']['email'], slack_userid: user_info['id'], slack_username: user_info['name'], name: user_info['profile']['real_name'])
      if @user.slack_username == nil
        @user.slack_username = user_info['name']
      end
      @user.save :validate => false
      sign_in_and_redirect @user
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
