require 'test_helper'

class SlackControllerTest < ActionDispatch::IntegrationTest
  test "should get search" do
    post slack_search_url, params: { text: "c++, ruby", response_url: "/" }
    assert_response :success
  end

  test "User search should fail on no params" do
    post slack_search_url, params: { text: "", response_url: "/" }
    assert_response :success
    assert_match(/Please specify at least one skill/, response.parsed_body["text"])
  end

  test "should get project_skills_search" do
    post slack_project_skills_search_url, params: { text: "ruby on rails", response_url: "/" }
    assert_response :success
  end

  test "Project search should fail on no params" do
    post slack_project_skills_search_url, params: { text: "", response_url: "/" }
    assert_response :success
    assert_match(/Please specify at least one skill/, response.parsed_body["text"])
  end

  test "should get project_search" do
    post slack_project_search_url, params: { text: "Project1", response_url: "/" }
    assert_response :success
  end

  test "Project user search should fail on no params" do
    post slack_project_search_url, params: { text: "", response_url: "/" }
    assert_response :success
    assert_match(/Please specify a project/, response.parsed_body["text"])
  end
end
