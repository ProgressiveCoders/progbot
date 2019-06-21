class SlackBot
  class << self
    def post_to_recruitment(user, testing = false)
      client.chat_postMessage(recruitment_params(user, testing))
    end

    def recruitment_params(user, testing = false)
      {
        channel: testing ? "#progbot" : '#recruitment',
        attachments: [
          {
            pretext: 'New User Signup',
            title: "A New User Has Signed Up: #{user.name}:::#{user.email}",
            title_link: Rails.application.routes.url_helpers.admin_user_url(user, :only_path => false),
            text: '',
            color: '#7CD197'
          }
        ]
      }.merge(default_params)
    end

    

    # def send_to_channel(volunteering, testing = true)
    #   channels = client.channels_list.channels
    #   channel = channels.detect { |c| c.name.match() == volunteering.project.slack_channel}
    #   client.chat_postMessage(volunteering_params(volunteering, testing))
    # end

    # def volunteering_params(volunteering, testing = true)
    #   {
    #     channel: testing ? '#progbot' : "'#'#{volunteering.project.slack_channel}",
    #     attachments: [
    #       {
    #         pretext: 'Volunteer Update',
    #         title: "There has been an update to a volunteering in #{volunteering.project.name}. Its status is now #{volunteering.state}. Check it out on ProgBot"
    #       }

    #     ]

    #   }
    # end

    def client
      @client = Slack::Web::Client.new
      @client.auth_test
      @client
    end

    def default_params
      { username: "Botty The ProgCode Bot"}
    end
    
    def lookup_by_email(email)
      @client.users_lookupByEmail(email: email).user
    rescue Slack::Web::Api::Errors::SlackError => e
      puts "SlackBot:  Email not found: #{email}"
      return nil
    end
  end
end
