require 'pry'

class SessionsController < ApplicationController

  def auth
    redirect_to root_path
  end

end
