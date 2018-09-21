require_relative "./base"
module SlackChatter
  module Api
    class Emoji < SlackChatter::Api::Base

      def list
        call_method("emoji", "list", {})
      end
    end
  end
end