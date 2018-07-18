class SkillsController < ApplicationController

  def tech_skills_index
    respond_to do |format|
      format.json { render json: Skill.tech_skills}
    end
  end

  def non_tech_skills_index
    respond_to do |format|
      format.json { render json: Skill.non_tech_skills}
    end
  end


end
