require 'omniauth/strategies/oauth2'
require 'uri'
require 'rack/utils'

module OmniAuth
  module Strategies
    class Slack < OmniAuth::Strategies::OAuth2

      option :client_options, {
        site: 'https://progcode.slack.com',
        token_url: 'https://slack.com/api/oauth.access'
      }

    end
  end
end
