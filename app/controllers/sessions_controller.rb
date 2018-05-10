require 'pry'

class SessionsController < ApplicationController

  def create
    @user = User.find_or_create_by(slack_userid: auth['uid'])
      if auth['info']['user']
        @user.slack_username = auth['info']['user']
      end
      @user.save
      session[:uid] = @user.slack_userid
    redirect_to welcome_dashboard_path
  end

  private

  def auth
    request.env['omniauth.auth']
  end
end
