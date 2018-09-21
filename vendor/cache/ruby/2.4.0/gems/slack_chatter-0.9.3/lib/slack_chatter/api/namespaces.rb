require_relative './api.rb'
require_relative './auth.rb'
require_relative './channels.rb'
require_relative './chat.rb'
require_relative './emoji.rb'
require_relative './files.rb'
require_relative './groups.rb'
require_relative './im.rb'
require_relative './oauth.rb'
require_relative './rtm.rb'
require_relative './search.rb'
require_relative './stars.rb'
require_relative './team.rb'
require_relative './users.rb'

module SlackChatter
  module Api
    module Namespaces
      extend self

      def method_missing(method, *args, &block)
        return super method, *args, &block unless allowed_namespaces.include?(method.to_s)
        self.class.send(:define_method, method) do
          method_sym = "@#{method}".to_sym
          self.instance_variable_get(method_sym) ||
            self.instance_variable_set(method_sym, "SlackChatter::Api::#{method.capitalize}".constantize.new(self))
        end
        self.send method, *args, &block
      end

      private

      def allowed_namespaces
        %w{api auth channels chat emoji files groups im oauth rtm search stars team users}
      end
    end
  end
end
