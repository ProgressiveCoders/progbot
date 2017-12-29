class APIController < ActionController::API
  include Secrets
  protect_from_forgery with: :exception

  def verify_token()
    if params[:token] != @VERIFICATION_TOKEN
      raise "verification token mismatch"
    end
  end

end
