module Playbook
  module Request 
    class BaseRequest
        
      attr_accessor :params
      attr_reader :current_user, :current_client_application

      def initialize(params)
        @params = (params || {}).dup
        @current_user = @params.delete(:current_user)
        @current_client_application = @params.delete(:current_client_application)
      end

      def response_class
        ::Playbook::Response::BaseResponse
      end

      def error_response_class
        ::Playbook::Response::BaseResponse
      end

    end
  end
end