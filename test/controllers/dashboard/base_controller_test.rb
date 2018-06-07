require 'test_helper'

class Dashboard::BaseControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dashboard_base_index_url
    assert_response :success
  end

end
