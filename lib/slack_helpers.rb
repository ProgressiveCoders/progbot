module SlackHelpers

    def self.client
        @client = Slack::Web::Client.new
        @client.auth_test
        @client
    end

    def self.get_slack_channels
      channels = Rails.cache.fetch('get_slack_channels', expires_in: 12.hours) do
        client.channels_list.channels
      end
      channels
    end
end