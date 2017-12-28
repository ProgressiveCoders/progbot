require 'test_helper'

class SlackControllerTest < ActionDispatch::IntegrationTest
  test "should get search" do
    get slack_search_url
    assert_response :success
  end

  test "should get project_search" do
    get slack_project_search_url
    assert_response :success
  end

end
