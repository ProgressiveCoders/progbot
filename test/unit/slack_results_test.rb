require 'slack_results'
class SlackResultsTest < Minitest::Test
  def test_response_body
    matching_users = User.where(name: "Robert")
    expected_response = {"attachments"=>[{:title=>"1 Result Found", :text=>"*Robert (MyString)*    C++, Java\n", :mrkdwn_in=>["text"]}], "mrkdwn"=>true}
    assert_equal expected_response, subject.send(:send_results, matching_users)
  end

  def test_response_body_when_no_results
    expected_response = {"attachments"=>[{"title": "No results found", "text": "No results"}]}
    assert_equal expected_response, subject.send(:send_results, [])
  end

  def test_when_params_are_missing_response_url_property
    assert_raises(KeyError) { SlackResults.new(UserSearch, {}) }
  end

  def subject
    @subject ||= SlackResults.new(UserSearch, { text: "foobar", response_url: "/"})
  end
end
