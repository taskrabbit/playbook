module Playbook
  module Response
    class ControllerResponse < BaseResponse
      def initialize(request, success, assigns = {})
        super(request, success, assigns)

        assigns.each do |k,v|
          @request.controller.instance_variable_set("@#{k}", v)
        end
        
      end
    end
  end
end