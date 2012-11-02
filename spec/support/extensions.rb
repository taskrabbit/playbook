module Playbook
  class << self
    def reset_config!
      @configuration = nil
    end
  end
end