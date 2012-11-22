require 'active_support/core_ext/hash/keys'

module Playbook
  module Response
    class BaseResponse

      def initialize(request, success, assigns = {})
        @request = request
        @success = !!success
        @assigns = (assigns || {})
        @assigns = {'object' => @assigns} unless @assigns.is_a?(Hash)
        @assigns = @assigns.stringify_keys
      end

      def success?
        @success
      end

      def failure?
        !self.success?
      end

      def method_missing(method_name, *args, &block)
        if args.empty? && @assigns.has_key?(method_name.to_s)
          return @assigns[method_name.to_s]
        else
          super
        end
      end

      def respond_to?(method_name, include_private = false)
        super || @assigns.has_key?(method_name.to_s)
      end

    end
  end
end