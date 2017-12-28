require 'application_helper'
require 'project'
require 'test_helper'

class ApplicationHelperTest < ActiveSupport::TestCase
  test "should only find optins" do
    skills = ['Java']
    userList = ApplicationHelper.queryUsers(skills)
    assert_not_empty(userList)
    userList.each do |user|
      assert_not_equal(user.name, "Charlie")
    end
  end

  test "should only match optins for project" do
    proj = Project.where(name: "Project1").first
    userList = ApplicationHelper.queryUsersForProject(proj)
    assert_not_empty(userList)
    userList.each do |user|
      assert_not_equal(user.name, "Charlie")
      assert_not_equal(user.name, "Robert")
      assert_not_equal(user.name, "Becca")
    end
  end
end