require 'slack_results'

class SlackController < APIController

  def search
    if params[:text].length > 0
      # tell the user to cool their heels
      render json: { response_type: "ephemeral", text: "performing search for: #{params[:text]}" }
      SlackResults.new(UserSearch, params).call
    else
      render json: { response_type: "ephemeral", text: "Please specify at least one skill" }
    end
  end

  def project_skills_search
    if params[:text].length > 0
      render json: { response_type: "ephemeral", text: "performing search for: #{params[:text]}" }
      res = SlackResults.new(ProjectSearch, params).call
    else
      render json: { response_type: "ephemeral", text: "Please specify at least one skill" }
    end
  end

  def project_search
    if params[:text].length > 0
      project = Project.where(name: params[:text]).first
      if project == nil
        render json: { response_type: "ephemeral", text: "project not found!" }
      else
        render json: { response_type: "ephemeral", text: "performing search: #{params[:text]}" }
        SlackResults.new(ProjectUsersSearch, params.merge({ project: project })).call
      end
    else
      render json: { response_type: "ephemeral", text: "Please specify a project" }
    end
  end
end
