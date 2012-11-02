module Playbook
  module Request 
    class BaseRequest
        
      def initialize(params)
        @params = params
      end

      def params
        @params
      end

      def response_class
        ::Playbook::Response::BaseResponse
      end

      def response_error_class
        ::Playbook::Response::BaseErrorResponse
      end

    end
  end
end