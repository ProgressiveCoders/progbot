class Hooks::ZapierController < ApplicationController
  before_action :authenticate_admin_user!

  def receive_airtable_updates
   
  end

  def test_connection
    byebug
    render json: {
      name: 'susanna',
      email: 'the'
    }.to_json
  end
end
