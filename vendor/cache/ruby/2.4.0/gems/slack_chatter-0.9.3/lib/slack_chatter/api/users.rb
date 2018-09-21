require_relative "./base"
module SlackChatter
  module Api
    class Users < SlackChatter::Api::Base

      def get_presence user_id
        call_method("users", "getPresence", {"user" => user_id})
      end

      def info user_id
        call_method("users", "info", {"user" => user_id})
      end

      def list
        call_method("users", "list", {})
      end

      def set_active
        call_method("users", "setActive", {})
      end

      def set_presence presence
        call_method("users", "setPresence", {"presence" => presence})
      end

    end
  end
end