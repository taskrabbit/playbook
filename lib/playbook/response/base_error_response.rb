module Playbook
  module Response
    class BaseErrorResponse < BaseResponse

      def initialize(request, error_message)
        super(request, false, {:error => error_message})
      end

    end
  end
end