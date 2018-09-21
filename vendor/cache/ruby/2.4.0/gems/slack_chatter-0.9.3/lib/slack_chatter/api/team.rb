require_relative "./base"
module SlackChatter
  module Api
    class Team < SlackChatter::Api::Base
      def access_logs opts={}
        call_method("team", "accessLogs", opts)
      end

      def info
        call_method("team", "info", {})
      end
    end
  end
end