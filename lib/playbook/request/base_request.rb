module Playbook
  module Request 
    class BaseRequest
        
      attr_accessor :params

      def initialize(params)
        @params = (params || {}).dup
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