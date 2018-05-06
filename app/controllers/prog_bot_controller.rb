class ProgBotController < ApplicationController
  def index
    @user = User.new(params[:user])
  end
end
