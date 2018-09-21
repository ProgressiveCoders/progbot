require_relative "./base"
module SlackChatter
  module Api
    class Search < SlackChatter::Api::Base
      def all query, opts={}
        opts = {"query" => query}.reverse_merge(opts)
        call_method("search", "all", opts)
      end

      def files query, opts={}
        opts = {"query" => query}.reverse_merge(opts)
        call_method("search", "files", opts)
      end

      def messages query, opts={}
        opts = {"query" => query}.reverse_merge(opts)
        call_method("search", "messages", opts)
      end
    end
  end
end