require 'project_users_search'

class UserSearchTest < ActiveSupport::TestCase
  def test_finds_only_optins
    project   = Project.first
    user_list = ProjectUsersSearch.new({ project: project }).call

    assert_not_empty(user_list)
    assert user_list.all?(&:optin)
  end

  def test_finds_users_when_given_comma_separated_search_term
    project   = Project.first
    skills    = project.skills.pluck(:name)
    user_list = UserSearch.new({ text: skills }).call

    assert_not_empty(user_list)
    assert user_list.none? {|u| (skills & u.skills.pluck(:name)).empty? },
      "Every user returned by project users search should have one of the skills needed by the project: #{project.name}"
  end
end
