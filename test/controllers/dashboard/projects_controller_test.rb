require 'test_helper'

class Dashboard::ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dashboard_project = dashboard_projects(:one)
  end

  test "should get index" do
    get dashboard_projects_url
    assert_response :success
  end

  test "should get new" do
    get new_dashboard_project_url
    assert_response :success
  end

  test "should create dashboard_project" do
    assert_difference('Dashboard::Project.count') do
      post dashboard_projects_url, params: { dashboard_project: {  } }
    end

    assert_redirected_to dashboard_project_url(Dashboard::Project.last)
  end

  test "should show dashboard_project" do
    get dashboard_project_url(@dashboard_project)
    assert_response :success
  end

  test "should get edit" do
    get edit_dashboard_project_url(@dashboard_project)
    assert_response :success
  end

  test "should update dashboard_project" do
    patch dashboard_project_url(@dashboard_project), params: { dashboard_project: {  } }
    assert_redirected_to dashboard_project_url(@dashboard_project)
  end

  test "should destroy dashboard_project" do
    assert_difference('Dashboard::Project.count', -1) do
      delete dashboard_project_url(@dashboard_project)
    end

    assert_redirected_to dashboard_projects_url
  end
end
