module Playbook
  module Controller
  
    protected

    def playbook_adapter_class
      self.class.name =~ /(^|:)([a-zA-Z0-9]+)Controller/
      wanted_adapter_name = "#{$2.to_s.singularize}Adapter"
      ::Playbook.matchers.most_relevant_class(self.class, wanted_adapter_name)
    end

    def playbook_request_class
      ::Playbook.matchers.most_relevant_class(self.class, 'ControllerRequest') || ::Playbook::Request::ControllerRequest
    end

    def adapter(force_reload = false)
      return @playbook_adapter unless force_reload || @playbook_adapter.nil?

      playbook_request = self.playbook_request_class.new(self)
      @playbook_adapter = self.playbook_adapter_class.new(playbook_request)
    end

    def validate_api_access!
      throttler.try(:record_request!)
      throttler.try(:validate_request!)
      stats = throttler.try(:stats)
      response.headers[Playbook.config.throttle_header] = stats if stats
    end

    def throttler
      nil
    end
    
    def api_version
      @api_version ||= ::Playbook.matchers.version_from_namespace(self.class)
    end
  end
end