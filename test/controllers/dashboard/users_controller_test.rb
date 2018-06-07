require 'test_helper'

class Dashboard::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dashboard_user = dashboard_users(:one)
  end

  test "should get index" do
    get dashboard_users_url
    assert_response :success
  end

  test "should get new" do
    get new_dashboard_user_url
    assert_response :success
  end

  test "should create dashboard_user" do
    assert_difference('Dashboard::User.count') do
      post dashboard_users_url, params: { dashboard_user: {  } }
    end

    assert_redirected_to dashboard_user_url(Dashboard::User.last)
  end

  test "should show dashboard_user" do
    get dashboard_user_url(@dashboard_user)
    assert_response :success
  end

  test "should get edit" do
    get edit_dashboard_user_url(@dashboard_user)
    assert_response :success
  end

  test "should update dashboard_user" do
    patch dashboard_user_url(@dashboard_user), params: { dashboard_user: {  } }
    assert_redirected_to dashboard_user_url(@dashboard_user)
  end

  test "should destroy dashboard_user" do
    assert_difference('Dashboard::User.count', -1) do
      delete dashboard_user_url(@dashboard_user)
    end

    assert_redirected_to dashboard_users_url
  end
end
