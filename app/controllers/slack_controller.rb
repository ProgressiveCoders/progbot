require 'net/http'

class SlackController < APIController
  before_action verify_token

  def search
    # tell the user to cool their heels
    render json response_type: "ephemeral", text: "performing search"
    # now send the search results to the response_url
    results = ApplicationHelper::queryUsers(params[:text].split(/\s*,\s*/))
    send_results(results, params)
  end

  def project_search
    project = Project.where(name: params[:text])
    if project == nil
      render json response_type: "ephemeral", text: "project not found!"
    else
      render json response_type: "ephemeral", text: "performing search"
      results = ApplicationHelper::queryUsersForProject(project)
      send_results(results, params)
    end
  end

  def send_results(results, params)
    uri = URI(params[:response_url])
    req = Net::Http::Post.new(uri)
    req.content_type = "application/json"
    result_body = {}
    if results.length > 0
      result_str = ""
      results.each do |user|
        result_str += user.name + "    "
        skill_list = []
        user.skills do |skill|
          skill_list.push(skill.name)
        end
        result_str += skill_list.join(", ") + "\n"
      end
      result_body["attachments"] = ["title": "#{results.length} Users Found", "text": result_str]
    else
      result_body["attachments"] = ["title": "No users found"]
    end

    req.body = result_body
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
  end
end
