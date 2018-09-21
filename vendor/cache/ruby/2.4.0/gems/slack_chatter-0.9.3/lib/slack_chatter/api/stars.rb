require_relative "./base"
module SlackChatter
  module Api
    class Stars < SlackChatter::Api::Base

      def list opts={}
        call_method("stars", "list", opts)
      end
    end
  end
end