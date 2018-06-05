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
    
    def client
      @client = Slack::Web::Client.new
      @client.auth_test
      @client
    end
    
    def default_params
      { username: "Botty The ProgCode Bot"}
    end
  end
end