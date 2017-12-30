require 'json'
require 'net/http'
require 'uri'

class SlackController < APIController

  def search
    # tell the user to cool their heels
    render json: { response_type: "ephemeral", text: "performing search for: #{params[:text]}" }
    Thread.new(params) { |params|
      # now send the search results to the response_url
      results = ApplicationHelper::queryUsers(params[:text].split(/\s*,\s*/))
      logger.debug results.inspect
      send_results(results, params)
    }
  end

  def project_search
    project = Project.where(name: params[:text])
    if project == nil
      render json: { response_type: "ephemeral", text: "project not found!" }
    else
      render json: { response_type: "ephemeral", text: "performing search" }
      Thread.new(project, params) { |project, params|
        results = ApplicationHelper::queryUsersForProject(project)
        send_results(results, params)
      }
    end
  end

  def send_results(results, params)
    logger.debug "send_results count #{results.count}"
    result_body = {}
    if results.count > 0
      logger.debug "count > 0"
      result_str = ""
      results.each do |user|
        result_str += "*#{user.name}* + "    "
        skill_list = []
        user.skills.each do |skill|
          skill_list.push(skill.name)
        end
        logger.debug "skill_list #{skill_list}"
        result_str += skill_list.join(", ") + "\n"
      end
      logger.debug "results #{result_str}"
      result_body["attachments"] = [{"title": "#{results.length} Users Found", "text": result_str}]
    else
      logger.debug "count 0"
      result_body["attachments"] = [{"title": "No users found", "text": "No results"}]
    end

    begin
      uri = URI(params[:response_url])
      res = Net::HTTP.post uri, result_body.to_json, "Content-Type" => "application/json"
      logger.debug "post result #{res}"
    rescue Exception => exc
      logger.error "error #{exc}"
    end
  end
end
