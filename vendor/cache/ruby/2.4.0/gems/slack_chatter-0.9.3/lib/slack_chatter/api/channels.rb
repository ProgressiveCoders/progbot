require_relative "./base"
module SlackChatter
  module Api
    class Channels < SlackChatter::Api::Base

      def find_by_name name
        list.channels.detect do |channel|
          channel["name"] == name
        end["id"]
      end

      def archive channel_id
        call_method("channels", "archive", {"channel" => channel_id})
      end

      def create channel_name
        # channel_name    - name of channel to recreate
        call_method("channels", "create", {"name" => channel_name})
      end

      def history channel_id, opts={}
        # latest          - End of time range of messages to include in results
        # oldest          - Start of time range of messages to include in results
        # inclusive       - Include messages with latest or oldest timestamp in results (send 0/1)
        # count           - Number of messages to return, between 1 and 1000
        call_method("channels", "history", {"channel" => channel_id}.merge(opts))
      end

      def info channel_id
        call_method("channels", "info", {"channel" => channel_id})
      end

      def invite channel_id, user_id
        call_method("channels", "invite", {"channel" => channel_id, "user" => user_id})
      end

      def join channel_name
        call_method("channels", "join", {"name" => channel_name})
      end

      def kick channel_id, user_id
        call_method("channels", "kick", {"channel" => channel_id, "user" => user_id})
      end

      def leave channel_id
        call_method("channels", "leave", {"channel" => channel_id})
      end

      def list exclude_archived=false
        # exclude_archives - Don't return archived channels (send 0/1)
        call_method("channels", "list", {"exclude_archived" => bool_as_i(exclude_archived)})
      end

      def mark channel_id, epoch_time_stamp
        # ts               - Timestamp of the most recently seen message
        call_method("channels", "mark", {"channel" => channel_id, "ts" => epoch_time_stamp})
      end

      def rename channel_id, new_name
        # new_name         - New name for channel
        call_method("channels", "rename", {"channel" => channel_id, "name" => new_name})
      end

      def set_purpose channel_id, purpose
        # purpose          - The new purpose for the channel
        call_method("channels", "setPurpose", {"channel" => channel_id, "purpose" => purpose})
      end

      def set_topic channel_id, topic
        # topic            - The new topic for the channel
        call_method("channels", "setTopic", {"channel" => channel_id, "topic" => topic})
      end

      def unarchive channel_id
        call_method("channels", "unarchive", {"channel"=> channel_id})
      end
    end
  end
end
