require 'test_helper'

class SlackControllerTest < ActionDispatch::IntegrationTest
  test "should get search" do
    post slack_search_url, params: { text: "c++, ruby", response_url: "/" }
    assert_response :success
  end

  test "should fail on no params" do
    post slack_search_url, params: { text: "", response_url: "/" }
    assert_response :success
  end

  test "should get project_skills_search" do
    post slack_project_skills_search_url, params: { text: "ruby on rails", response_url: "/" }
    assert_response :success
  end

  test "should get project_search" do
    post slack_project_search_url, params: { text: "Project1", response_url: "/" }
    assert_response :success
  end
end
