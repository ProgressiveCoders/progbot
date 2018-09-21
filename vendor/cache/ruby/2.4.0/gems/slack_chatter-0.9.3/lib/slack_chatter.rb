require "slack_chatter/version"
require "slack_chatter/client"
require 'logger'

module SlackChatter
  class << self

    def logger(level=Logger::INFO)
      @logger = Logger.new(STDOUT) unless defined?(@logger) and @logger.level != level
      @logger.level = level
      @logger
    end
  end
end
