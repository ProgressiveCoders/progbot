class Hooks::ZapierController < ApplicationController
  before_action -> { doorkeeper_authorize! :write }

  def receive_airtable_updates
   
  end

  def home
    render json: {message: "You are Home"}.to_json
  end

  private

  def current_resource_owner
    HookUser.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
  
  def current_hook_user
    current_resource_owner
  end

  def authenticate_scope!
    self.resource = send(:"current_#{resource_name}")
  end

  
end
