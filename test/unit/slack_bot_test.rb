require 'slack_bot'

class SlackBotTest < Minitest::Test
  def test_post_to_recruitment
    User.skip_callback(:create, :after, :send_slack_notification)
    user = User.create!(
      name: "Robert",
      email: "MyString",
      join_reason: "MyText",
      hear_about_us: "MyText",
      overview: "MyText",
      location: "MyString",
      anonymous: false,
      phone: "MyString",
      slack_username: "MyString",
      read_manifesto: true,
      read_code_of_conduct: true,
      referer: nil,
      optin: true
    )
    
    expected_response = {
      :channel      => "#recruitment",
      :attachments  => [
        {
          :pretext    => "New User Signup",
          :title      => "A New User Has Signed Up: Robert:::MyString",
          :title_link => "http://progressive-coders-bot.test.com/admin/users/#{user.id}",
          :text       => "",
          :color      => "#7CD197"
        }
      ],
      :username   => "Botty The ProgCode Bot"
    }
    
    
    assert_equal expected_response, subject.send(:recruitment_params, user)
  end

  def subject
    @subject ||= SlackBot
  end
end
