class SlackBot
  include SlackHelpers
  class << self
    def send_message(params, testing = true)
      SlackHelpers.client.chat_postMessage(parse_params(params, testing))
    end

    def parse_params(params, testing)
      self.merge_params(default_params, {
        channel: testing ? "#progbot" : params[:channel],
        attachments: params[:attachments]
      })
    end

    def default_params
      { username: "Botty The ProgCode Bot",
        color: '#7CD197',
        text: '',
      }
    end

    def merge_params(default, added)
      default.merge(added) do |key, default_value, added_value|
        key == :attachments ? [default_value[0].merge(added_value[0])] : key = added_value
      end

    end
    
  end
end
