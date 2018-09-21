module SlackChatter
  module Api
    class Base
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      def channel_id_or_name

      end

      def call_method(name_space, slack_method, params, http_method=:get)
        path = "#{name_space}.#{slack_method}"
        if http_method.to_sym == :get
          client.get(path, params)
        else
          client.post(path, params)
        end
      end

      def bool_as_i(bool)
        bool ? 1 : 0
      end

    end
  end
end
