require 'ostruct'

module SlackChatter
  class Response < OpenStruct
    attr_reader :response

    def initialize response
      parsed_res = JSON.parse(response.body)
      super(parsed_res)
      self.response = response
      self.code = response.code
    end

    def to_h
      marshal_dump.with_indifferent_access
    end

    def to_json
      JSON.dump(to_h)
    end

    def success?
      parsed_res["ok"]
    end

    def failed?
      !parsed_res["ok"]
    end

  end
end