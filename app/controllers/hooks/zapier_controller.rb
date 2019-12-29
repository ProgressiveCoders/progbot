class Hooks::ZapierController < ApplicationController
  before_action :authenticate_hook_user

  def receive_airtable_updates
   
  end

  def test_connection
    render json: {
      name: 'susanna',
      email: 'the'
    }.to_json
  end

  def home
    render plain: "You are Home"
  end

  private

  def authenticate_hook_user
    if request.headers['Authorization'].present?
      authenticate_or_request_with_http_token do |token|
        begin
          jwt_payload = JWT.decode(token, Rails.application.secrets.secret_key_base).first

          @current_hook_user_id = jwt_payload['id']
        rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
          head :unauthorized
        end
      end
    end
  end

  def authenticate_hook_user!(options = {})
    head :unauthorized unless hook_user_signed_in?
  end

  def current_hook_user
    @current_hook_user ||= super || HookUser.find(@current_hook_user_id)
  end

  def signed_in?
    @current_hook_user_id.present?
  end
end
