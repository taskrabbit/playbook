require 'jbuilder'

module Playbook
  module Jbuilder
    extend ActiveSupport::Concern

    included do
      alias_method_chain :target!, :jsonp
      alias_method_chain :extract!, :api_type
    end

    def jsonp!(callback_name)
      @jsonp_callback = callback_name
    end

    def target_with_jsonp!
      json = target_without_jsonp!
      if @jsonp_callback
        "#{@jsonp_callback}(#{json})"
      else
        json
      end
    end
  end
end