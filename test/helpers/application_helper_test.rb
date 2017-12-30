require 'application_helper'
require 'project'
require 'test_helper'

class ApplicationHelperTest < ActiveSupport::TestCase
  test "should only find optins" do
    skills = ['java']
    userList = ApplicationHelper.queryUsers(skills)
    assert_not_empty(userList)
    refute_includes userList.map(&:name), "Charlie"
  end

  test "should only match optins for project" do
    proj = Project.where(name: "Project1").first
    userList = ApplicationHelper.queryUsersForProject(proj)
    assert_not_empty(userList)
    userList.each do |user|
      # didn't opt in
      assert_not_equal(user.name, "Charlie")
      # lead for the project
      assert_not_equal(user.name, "Robert")
      # volunteer for the project
      assert_not_equal(user.name, "Becca")
    end
  end
end
