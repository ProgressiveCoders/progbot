require 'application_helper'
require 'test_helper'

class ApplicationHelperTest < ActiveSupport::TestCase
  include ApplicationHelper
  test "should only find optins" do
    skills = ['Java']
    userList = queryUsers(skills)
    userList.each do |user|
      assert_not_equal(user.name, "Charlie")
    end
  end
end
