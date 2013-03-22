require 'active_support/core_ext/module/delegation'

module Playbook
  module Errors
    
    # base class. catch this in your execution blocks
    class Error < ::StandardError; end

    class OverRateLimitError < Error; end
    class ControllerNotInitializedError < Error; end
    class GeneralError < Error; end

    class AuthenticationError < Error
      def initialize(path)
        super("#{path} requires authentication")
      end

      def status
        401
      end
    end

    class AdminError < Error
      def initialize(path)
        super("Only admins can access #{path}")
      end

      def status
        401
      end
    end

    class ResponseNotProvidedError < Error
      def initialize(adapter, method_name)
        super("No response was provided by #{adapter}##{method_name}")
      end
    end

    class DocumentationNotProvidedError < Error
      
      attr_accessor :message_content
      
      def initialize(klazz, meth)
        super("You must provide documenation for #{klazz.name}##{meth}")
      end
    
    end

    class AccessNotGrantedError < Error
      def status
        412
      end
    end


    class RequiredParameterMissingError < Error
      def initialize(keys)
        super("Missing these required params: #{keys.join(', ')}")
      end

      def status
        412
      end
    end
    
    class NotFoundError < Error
      def initialize(message = nil)
        super(message || "Not Found")
      end

      def status
        404
      end
    end

    class AuthorizationError < Error
      def initialize(message=nil)
        super(message || "Forbidden")
      end

      def status
        403
      end
    end


    class ObjectError < Error
      
      def initialize(object)
        @object = object
      end

      def error_object
        @object
      end

      def error_object_id
        @object.respond_to?(:id) ? @object.id : nil
      end
      
      def error_object_type
        @object.class.name
      end
          
      def error_messages
        by_name = {}
        @object.errors.each{|name, msg| (by_name[name] ||= []) << msg }
        by_name.map do |key, msgs|
          name = @object.class.human_attribute_name(key.to_s.gsub(/^.*\./,''))
          {
            :key      => key,
            :message  => "#{key.to_s == 'base' ? '' : "#{name} "}#{msgs.join(' & ')}",
            :raw      => msgs
          }
        end
      end
    end

    class EndpointNotSupportedError < Error

      attr_reader :path, :api_version, :extra
      
      def initialize(path, api_version, message = nil, status = 404)
        message ||= "NOT FOUND at #{path}"
        super(message)
        @status = status
      end

      def status
        @status
      end
    end

  end
end