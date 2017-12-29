class APIController < ActionController::API
  include Secrets

  def verify_token()
    if params[:token] != @VERIFICATION_TOKEN
      raise "verification token mismatch"
    end
  end

end
