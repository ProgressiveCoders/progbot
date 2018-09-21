require_relative "./base"
module SlackChatter
  module Api
    class Oauth < SlackChatter::Api::Base
      def access client_id, client_secret, code, opts={}
        opts.merge!({
          "client_id" => client_id,
          "client_secret" => client_secret,
          "code" => code})
        call_method("oauth", "access", opts)
      end
    end
  end
end