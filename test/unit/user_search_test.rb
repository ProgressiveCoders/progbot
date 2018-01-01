require 'user_search'

class UserSearchTest < ActiveSupport::TestCase
  def test_finds_only_optins
    skills    = 'java'
    user_list = UserSearch.new({ text: skills }).call

    assert_not_empty(user_list)
    assert user_list.all?(&:optin)
  end

  def test_finds_users_when_given_comma_separated_search_term
    skills    = 'ruby, c++'
    user_list = UserSearch.new({ text: skills }).call

    assert_not_empty(user_list)
    assert user_list.none? {|u| (['ruby', 'c++'] & u.skills.pluck(:name).map(&:downcase)).empty? },
      "Every user returned by user search should have one of the skills: #{skills}"
  end
end
