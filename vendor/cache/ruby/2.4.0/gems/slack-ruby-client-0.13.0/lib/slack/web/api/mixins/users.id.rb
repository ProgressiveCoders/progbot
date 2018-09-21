require_relative 'ids.id'

module Slack
  module Web
    module Api
      module Mixins
        module Users
          include Ids
          #
          # This method returns a user ID given a user name.
          #
          # @option options [user] :user
          #   User to get ID for, prefixed with '@'.
          def users_id(options = {})
            name = options[:user]
            throw ArgumentError.new('Required arguments :user missing') if name.nil?

            id_for(:user, name, '@', :members, 'user_not_found') do
              users_list
            end
          end
        end
      end
    end
  end
end
