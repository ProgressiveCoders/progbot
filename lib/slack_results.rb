require_relative 'user_search'
require_relative 'project_users_search'
class SlackResults
  attr_reader :search_text, :response_url
  def initialize(search_class, params)
    @search_class = search_class
    @params       = params
    @response_url = params.fetch(:response_url)
  end

  def call
    Thread.new(@search_text) { |search_text|
      results = @search_class.new(@params).call

      logger.debug results.inspect

      send_results(results)
    }
  end

  private
    def send_results(results)
      logger.debug "send_results count #{results.count}"
      result_body = {}
      if results.present?
        logger.debug "count > 0"
        result_str = ""
        results.each do |user|
          result_str += "*#{user.name}*    "
          skill_list = user.skills.order(:name).pluck(:name)
          logger.debug "skill_list #{skill_list}"
          result_str += skill_list.join(", ") + "\n"
        end
        logger.debug "results #{result_str}"
        s = results.count != 1 ? "s" : ""
        result_body["attachments"] = [{"title": "#{results.count} User#{s} Found", "text": result_str, "mrkdwn_in": ["text"]}]
        result_body["mrkdwn"] = true
      else
        logger.debug "count 0"
        result_body["attachments"] = [{"title": "No users found", "text": "No results"}]
      end

      begin
        uri = URI(@response_url)
        res = Net::HTTP.post uri, result_body.to_json, "Content-Type" => "application/json"
        logger.debug "post result #{res}"
      rescue Exception => exc
        logger.error "error #{exc}"
      end

      return result_body
    end

    def logger
      Rails.logger
    end
end
