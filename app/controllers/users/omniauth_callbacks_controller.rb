# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController


  def slack
    auth = request.env['omniauth.auth']
    Rails.logger.info "SLACKK OMNIAUTH\n" + auth.inspect
    # check to make sure team id is correct
    @user = User.find_by(email: auth['info']['email']) || User.find_by(slack_userid: auth['uid'])
    if @user
      if !@user.slack_userid || @user.slack_userid != auth['uid']
        @user.slack_userid = auth['uid']
        @user.slack_username = auth['info']['user']
        @user.save
      end
      if !@user.email != auth['info']['email']
        @user.email = auth['info']['email']
      end
      sign_in_and_redirect @user
    else
      @user = User.new(is_approved: true, email: auth['info']['email'], slack_userid: auth['uid'], slack_username: auth['info']['user'], name: auth['info']['name'])
      if @user.slack_username == nil
        @user.slack_username = auth['info']['name']
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
