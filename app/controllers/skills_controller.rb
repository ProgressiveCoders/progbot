class SkillsController < ApplicationController
    inherit_resources
    before_action :authenticate_user!


end
