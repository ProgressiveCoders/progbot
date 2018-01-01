require 'user_search'

class ProjectSearchTest < ActiveSupport::TestCase
  def test_finds_users_when_given_comma_separated_search_term
    skills    = 'c++, ruby on rails'
    project_list = ProjectSearch.new({ text: skills }).call

    assert_not_empty(project_list)
    assert project_list.none? {|p| (['ruby on rails', 'c++'] & p.skills.pluck(:name).map(&:downcase)).empty? },
      "Every project returned by project search should have one of the skills: #{skills}"
  end
end
