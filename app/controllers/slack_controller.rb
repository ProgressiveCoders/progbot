require 'slack_results'

class SlackController < APIController

  def search
    if params[:text].empty?
      render json: { response_type: "ephemeral", text: "Please specify at least one skill" }
    else
      # tell the user to cool their heels
      render json: { response_type: "ephemeral", text: "performing search for: #{params[:text]}" }
      SlackResults.new(UserSearch, params).call
    end
  end

  def project_skills_search
    if params[:text].empty?
      render json: { response_type: "ephemeral", text: "Please specify at least one skill" }
    else
      render json: { response_type: "ephemeral", text: "performing search for: #{params[:text]}" }
      res = SlackResults.new(ProjectSearch, params).call
    end
  end

  def project_search
    if params[:text].empty?
      render json: { response_type: "ephemeral", text: "Please specify a project" }
    else
      project = Project.where(name: params[:text]).first
      if project == nil
        render json: { response_type: "ephemeral", text: "project not found!" }
      else
        render json: { response_type: "ephemeral", text: "performing search: #{params[:text]}" }
        SlackResults.new(ProjectUsersSearch, params.merge({ project: project })).call
      end
    end
  end

  def project_list
    render json: { response_type: "ephemeral", text: "getting projects" }
    SlackResults.new(ProjectList, params).call
  end
end
