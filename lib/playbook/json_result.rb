module Playbook
  class JsonResult < ::String
    def initialize(string)
      @string = string
    end

    def encode_json(encoder)
      @string
    end
  end
end