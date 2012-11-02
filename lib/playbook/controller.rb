module Playbook
  module Controller
  
    def adapter
      self.name =~ /(^|:)([a-zA-Z0-9]+)Controller/
      wanted_adapter_name = $2.to_s.singularize
      ::Playbook.matchers.most_relevant_class(self, wanted_adapter_name)
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