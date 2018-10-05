class Dashboard::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :set_skills
  layout "dashboard"
  
  def index
  end
end
