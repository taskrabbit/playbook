module Playbook
  module Response
    class ControllerErrorResponse < ControllerResponse

      # controllers handle errors nicely
      def initialize(request, success, error_object_or_String)
        raise ::Playbook::Errors::ObjectError.new(error_object_or_String) if error_object_or_String.respond_to?(:errors)
        raise ::Playbook::Errors::GeneralError.new(error_object_or_String.to_s)
      end
    end
  end
end