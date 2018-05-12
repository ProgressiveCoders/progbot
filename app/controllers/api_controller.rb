require 'pry'
class APIController < ActionController::API
  @@SLACK_VERIFICATION_TOKEN = ENV['SLACK_VERIFICATION_TOKEN']
  @@SLACK_CLIENT_ID = ENV['SLACK_CLIENT_ID']
  @@SLACK_CLIENT_SECRET = ENV['SLACK_CLIENT_SECRET']

  before_action :verify_token
  def verify_token
    binding.pry
    if params[:token] != @@SLACK_VERIFICATION_TOKEN
      raise "verification token mismatch"
    end
  end

end
