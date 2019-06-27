module SlackHelpers

    def client
        @client = Slack::Web::Client.new
        @client.auth_test
        @client
      end
end