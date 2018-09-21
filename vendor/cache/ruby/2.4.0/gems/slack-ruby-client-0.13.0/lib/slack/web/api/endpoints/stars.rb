# This file was auto-generated by lib/tasks/web.rake

module Slack
  module Web
    module Api
      module Endpoints
        module Stars
          #
          # Adds a star to an item.
          #
          # @option options [channel] :channel
          #   Channel to add star to, or channel where the message to add star to was posted (used with timestamp).
          # @option options [file] :file
          #   File to add star to.
          # @option options [Object] :file_comment
          #   File comment to add star to.
          # @option options [Object] :timestamp
          #   Timestamp of the message to add star to.
          # @see https://api.slack.com/methods/stars.add
          # @see https://github.com/slack-ruby/slack-api-ref/blob/master/methods/stars/stars.add.json
          def stars_add(options = {})
            options = options.merge(channel: channels_id(options)['channel']['id']) if options[:channel]
            post('stars.add', options)
          end

          #
          # Lists stars for a user.
          #
          # @option options [Object] :cursor
          #   Parameter for pagination. Set cursor equal to the next_cursor attribute returned by the previous request's response_metadata. This parameter is optional, but pagination is mandatory: the default value simply fetches the first "page" of the collection. See pagination for more details.
          # @option options [Object] :limit
          #   The maximum number of items to return. Fewer than the requested number of items may be returned, even if the end of the list hasn't been reached.
          # @see https://api.slack.com/methods/stars.list
          # @see https://github.com/slack-ruby/slack-api-ref/blob/master/methods/stars/stars.list.json
          def stars_list(options = {})
            if block_given?
              Pagination::Cursor.new(self, :stars_list, options).each do |page|
                yield page
              end
            else
              post('stars.list', options)
            end
          end

          #
          # Removes a star from an item.
          #
          # @option options [channel] :channel
          #   Channel to remove star from, or channel where the message to remove star from was posted (used with timestamp).
          # @option options [file] :file
          #   File to remove star from.
          # @option options [Object] :file_comment
          #   File comment to remove star from.
          # @option options [Object] :timestamp
          #   Timestamp of the message to remove star from.
          # @see https://api.slack.com/methods/stars.remove
          # @see https://github.com/slack-ruby/slack-api-ref/blob/master/methods/stars/stars.remove.json
          def stars_remove(options = {})
            options = options.merge(channel: channels_id(options)['channel']['id']) if options[:channel]
            post('stars.remove', options)
          end
        end
      end
    end
  end
end
