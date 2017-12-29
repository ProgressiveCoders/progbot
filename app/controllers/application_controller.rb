class ApplicationController < ActionController::Base
  include Secrets
  protect_from_forgery with: :exception

  def verify_token() {
    assert params[:token] == @VERIFICATION_TOKEN
  }

end
