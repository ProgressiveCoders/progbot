class ProjectsController < ApplicationController
    inherit_resources
    before_action :authenticate_user!

    def index
      @alphabetized_projects = Project.all.sort_by(&:name)
    end


end