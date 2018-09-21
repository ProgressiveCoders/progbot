require_relative "./base"
module SlackChatter
  module Api
    class Api < SlackChatter::Api::Base

      def test opts={}
        call_method("api", "test", opts)
      end

    end
  end
end