module Playbook
  module Response
    class ControllerErrorResponse < ControllerResponse

      def initialize(request, object)
        super(request, false, {})
        raise ::Playbook::Errors::ObjectError.new(object)
      end

    end
  end
end