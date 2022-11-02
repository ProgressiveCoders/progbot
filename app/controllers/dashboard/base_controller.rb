class Dashboard::BaseController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def index

  end

  def search
    @results = {skills: Skill.simple_search(params[:q]), projects: Project.simple_search(params[:q]), users: UserSearch.new({text: params[:q]}).call}
  end
end
