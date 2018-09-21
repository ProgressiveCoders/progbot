require_relative "./base"
module SlackChatter
  module Api
    class Files < SlackChatter::Api::Base
      def delete file_id
        call_method("files", "delete", {"file" => file_id})
      end

      def info file_id, opts={}
        call_method("files", "info", {"file" => file_id}.merge(opts))
      end

      def list opts={}
        call_method("files", "list", opts)
      end

      def upload opts={}
        opts = opts.with_indifferent_access
        filename = opts.delete(:file) || opts.delete(:content)
        client.post("files.upload", {}, query: opts.merge({file: UploadIO.new(File.open(filename), "multipart/form-data")}))
      end
    end
  end
end