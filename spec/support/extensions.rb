module Playbook
  class << self
    def reset_config!
      Singleton.send :__init__, Playbook::Configuration
    end
  end
end