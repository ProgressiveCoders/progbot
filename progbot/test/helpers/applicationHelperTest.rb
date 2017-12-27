require 'application_helper'
require 'project'
require 'test_helper'

class ApplicationHelperTest < ActiveSupport::TestCase
  include ApplicationHelper
  test "should only find optins" do
    skills = ['Java']
    userList = queryUsers(skills)
    assert_not_empty(userList)
    userList.each do |user|
      assert_not_equal(user.name, "Charlie")
    end
  end

  test "should only match optins for project" do
    proj = Project.where(name: "Project1").first
    userList = queryUsersForProject(proj)
    assert_not_empty(userList)
    userList.each do |user|
      assert_not_equal(user.name, "Charlie")
    end
  end
end
