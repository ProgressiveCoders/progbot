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

    def self.get_channel_info(id)
      client.channels_info(channel: id)
    end

    def self.lookup_by_email(email)
      self.client.users_lookupByEmail(email: email).user
    rescue Slack::Web::Api::Errors::SlackError => e
      puts "SlackBot:  Email not found: #{email}"
      return nil
    end
end