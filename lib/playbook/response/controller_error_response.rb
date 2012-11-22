module Playbook
  module Response
    class ControllerErrorResponse < ControllerResponse

      # controllers handle errors nicely
      def initialize(request, success, error_object_or_string)
        raise ::Playbook::Errors::ObjectError.new(error_object_or_string) if error_object_or_string.respond_to?(:errors)
        raise ::Playbook::Errors::GeneralError.new(error_object_or_string.to_s)
      end
    end
  end
end