# this controller is deprecated and will be deleted once i make sure none of it is still needed
class SessionsController < ApplicationController

  def create
    #called when user signs in with slack
    @user = User.find_by(email: auth['info']['email'])
      if @user
        if !@user.slack_userid || @user.slack_userid != auth['uid']
          @user.slack_userid = auth['uid']
          @user.slack_username = auth['info']['user']
        end
        if @user.save
          session[:uid] = @user.id
          redirect_to welcome_dashboard_path
        else
          redirect_to edit_users_path
        end
      else
        redirect_to new_users_path
        session[:params] = auth['info']
        #for users who are already a member of progcode's slack channel but not progbot
      end
  end

  def destroy
    session.delete :uid
    session.delete :params
    redirect_to root_path
  end

  private

  def auth
    request.env['omniauth.auth']
  end
end
