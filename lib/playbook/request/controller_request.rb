require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/hash/except'

module Playbook
  module Request
    class ControllerRequest < BaseRequest

      delegate :current_user, :current_client_application, :to => :@controller
      attr_reader :controller
      
      def initialize(controller)
        super(controller.params.except(:controller, :action, :format, 'controller', 'action', 'format'))
        @controller = controller
      end

      def response_class
        ::Playbook::Response::ControllerResponse
      end

      def error_response_class
        ::Playbook::Response::ControllerErrorResponse
      end

    end
  end
end