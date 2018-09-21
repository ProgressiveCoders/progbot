require_relative "./base"
module SlackChatter
  module Api
    class Im < SlackChatter::Api::Base


      def close user_id
        call_method("im", "close", {"user" => user_id})
      end

      def history user_id, opts={}
        # latest          - End of time range of messages to include in results
        # oldest          - Start of time range of messages to include in results
        # inclusive       - Include messages with latest or oldest timestamp in results (send 0/1)
        # count           - Number of messages to return, between 1 and 1000
        call_method("im", "history", {"user" => user_id}.merge(opts))
      end

      def list
        # exclude_archives - Don't return archived im (send 0/1)
        call_method("im", "list", {})
      end

      def mark user_id, epoch_time_stamp
        # ts               - Timestamp of the most recently seen message
        call_method("im", "mark", {"user" => user_id, "ts" => epoch_time_stamp})
      end

      def open user_id
        call_method("im", "open", {"user" => user_id})
      end
    end
  end
end