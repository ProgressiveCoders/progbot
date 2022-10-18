module SlackHelpers

    def self.client
        @client = Slack::Web::Client.new
        @client.auth_test
        @client
    end

    def self.get_slack_channels
      channels = Rails.cache.fetch('get_slack_channels', expires_in: 12.hours) do
        client.conversations_list.channels
      end
      channels
    end

    def self.get_channel_info(id)
      client.conversations_info(channel: id)
    end

    def self.lookup_by_email(email)
      self.client.users_lookupByEmail(email: email).user
    rescue Slack::Web::Api::Errors::SlackError => e
      puts "SlackBot:  Email not found: #{email}"
      return nil
    end

    def self.lookup_by_slack_id(slack_id)
      self.client.users_info(user: slack_id).user.profile
    rescue Slack::Web::Api::Errors::SlackError => e
      puts "SlackBot:  ID not found: #{slack_id}"
      return nil
    end

    def self.lookup_by_slack_username(slack_username)
      self.client.users_info(user: "@#{slack_username}").user.profile
    rescue Slack::Web::Api::Errors::SlackError => e
      puts "SlackBot: username not found: #{slack_username}"
      return nil
    end
end