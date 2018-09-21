require_relative "./base"
module SlackChatter
  module Api
    class Auth < SlackChatter::Api::Base

      def test
        call_method("auth", "test", {})
      end

    end
  end
end