
require 'httmultiparty'
require 'active_support'
require 'active_support/core_ext'

require 'slack_chatter/api/namespaces'
require 'slack_chatter/response'

module SlackChatter
  class Client

    include SlackChatter::Api::Namespaces

    attr_reader :access_token, :username, :icon_url, :namespaces

    def initialize(access_token, opts={})
      opts = opts.with_indifferent_access.reject{|_,v| v.nil?}
      opts.reverse_merge!(default_slack_configuration)

      @access_token   =     access_token
      @username       =     opts[:username]
      @icon_url       =     opts[:icon_url]
      @uri_scheme     =     opts[:uri_scheme]
      @uri_host       =     opts[:uri_host]
      @uri_base_path  =     opts[:uri_base_path]
      @uri_port       =     opts[:uri_port]
    end

    def default_slack_configuration
      {
        uri_scheme:     "https",
        uri_host:       "slack.com",
        uri_base_path:  "/api"
      }
    end

    # Perform an HTTP GET request
    def get(path, query_params={}, opts={})
      request(:get, path, query_params, opts)
    end

    # Perform an HTTP POST request
    def post(path, query_params={}, opts={})
      request(:post, path, query_params, opts)
    end

    def api_uri_root()
      # Changed this from URI.join because scheme became pointless. It could not
      # override the scheme set in the host and the scheme was required to be set
      # in @uri_host or else URI.join throws an error
      URI.parse('').tap do |uri|
        uri.scheme = @uri_scheme
        uri.host   = @uri_host.gsub(/https?:\/\//, '') # strip the scheme if it is part of the hostname
        uri.path   = [@uri_base_path,nil].join('/')
        uri.port   = @uri_port unless @uri_port.blank?
      end.to_s
    end

    def request(method, path, query_params={}, opts={})
      query_params = query_params.merge({token: @access_token})
      uri = full_url(path, query_params)

      SlackChatter.logger.info("SlackChatter::Client   #{method}-ing #{uri} with params #{opts.merge(headers: headers)}")
      response = HTTMultiParty.send(method, uri, opts.merge(headers: headers))

      if !response.code =~ /20[0-9]/
        SlackChatter.logger.fatal("SlackChatter::Client   #{response.code} #{method}-ing #{uri.to_s} #{response.parsed_response}")
      else
        SlackChatter.logger.debug("SlackChatter::Client   #{uri} response: #{response.body}")
      end
      response.body.force_encoding("utf-8") if response.body and response.body.respond_to?(:force_encoding)
      SlackChatter::Response.new(response)
    end

    def set_logger(level)
      SlackChatter.logger(level)
    end

    private
    # Fully qualified url
    def full_url(path, query_params)
      uri = URI.join(api_uri_root, path)
      uri.query = query_params.to_query
      uri.to_s
    end

    def headers
      {
        "Connection"    => 'keep-alive',
        "Accept"        => 'application/json'
      }
    end

    def options(params={})
      headers.merge(params)
    end
  end
end