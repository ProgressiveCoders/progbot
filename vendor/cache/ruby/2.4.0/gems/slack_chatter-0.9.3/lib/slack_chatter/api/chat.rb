require_relative "./base"
module SlackChatter
  module Api
    class Chat < SlackChatter::Api::Base
      def post_message(channel_id, text, opts={})
        res = call_method("chat", "postMessage", {"channel" => channel_id, "text" => text}.merge(opts))
        if res.ok
          return res
        else
          client.channels.find_by_name(channel_id.gsub('#', '').downcase)
          res = call_method("chat", "postMessage", {"channel" => channel_id, "text" => text}.merge(opts))
        end
      end

      def delete(timestamp, channel_id)
        call_method("chat", "delete", {"channel" => channel_id, "ts" => timestamp})
      end

      def update(timestamp, channel_id, text)
        call_method("chat", "update", {"channel" => channel_id, "ts" => timestamp, "text" => text})
      end
    end
  end
end
