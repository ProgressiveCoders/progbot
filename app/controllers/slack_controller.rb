require 'slack_results'

class SlackController < APIController

  def search
    # tell the user to cool their heels
    render json: { response_type: "ephemeral", text: "performing search for: #{params[:text]}" }
    SlackResults.new(UserSearch, params).call
  end

  def project_search
    project = Project.where(name: params[:text]).first
    if project == nil
      render json: { response_type: "ephemeral", text: "project not found!" }
    else
      render json: { response_type: "ephemeral", text: "performing search: #{params[:text]}" }
      SlackResults.new(ProjectUsersSearch, params.merge({ project: project })).call
    end
  end
end
