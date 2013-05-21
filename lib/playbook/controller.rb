module Playbook
  module Controller
    def playbook_adapter_class
      controller_scope = resolver_class.name.split(self.api_version.to_namespace).last
      controller_scope =~ /::(.+)Controller$/
      return nil unless $1
      wanted_adapter_name = "#{$1.singularize}Adapter"
      ::Playbook::Matcher.most_relevant_class(resolver_class, wanted_adapter_name)
    end

    def playbook_request_class
      ::Playbook::Matcher.most_relevant_class(resolver_class, 'ControllerRequest') || ::Playbook::Request::ControllerRequest
    end

    def adapter(force_reload = false)
      return @playbook_adapter unless force_reload || @playbook_adapter.nil?

      playbook_request  = self.playbook_request_class.new(self)
      @playbook_adapter = self.playbook_adapter_class.new(playbook_request)
    end
    
    def api_version
      @api_version ||= ::Playbook::Matcher.version_from_namespace(resolver_class)
    end
    
    def resolver_class
      self.class
    end
  end
end