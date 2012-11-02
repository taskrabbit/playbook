require 'active_support/core_ext/module/delegation'

module Playbook
  module Errors
    
    class AccessNotGrantedError < StandardError; end
    class OverRateLimitError < StandardError; end
    class ControllerNotInitializedError < StandardError; end
    class GeneralError < StandardError; end

    class ResponseNotProvidedError < StandardError
      def initialize(adapter, method_name)
        super("No response was provided by #{adapter}##{method_name}")
      end
    end

    class DocumentationNotProvidedError < StandardError
      
      attr_accessor :message_content
      
      def initialize(klazz, meth)
        super("You must provide documenation for #{klazz.name}##{meth}")
      end
    
    end

    class RequiredParameterMissingError < StandardError
      def initialize(keys, any_of = false)
        super("Missing #{any_of ? 'at least one of these params' : 'these required params'}: #{keys.join(', ')}")
      end
    end


    class ObjectError < StandardError
      
      delegate :id, :to => :object, :prefix => :object
      
      def initialize(object)
        @object = object
      end

      def object
        @object
      end
      
      def object_type
        @object.class.name
      end
          
      def error_messages
        by_name = {}
        @object.errors.each{|name, msg| (by_name[name] ||= []) << msg }
        by_name.map do |key, msgs|
          name = @object.class.human_attribute_name(key.to_s.gsub(/^.*\./,''))
          {
            :key => key,
            :message => "#{key == 'base' ? '' : "#{name} "}#{msgs.join(' & ')}" 
          }
        end
      end
    end

    class EndpointNotSupportedError < StandardError

      attr_reader :path, :api_version, :extra
      
      def initialize(path, api_version, extra = nil)
        @path = path
        @api_version = api_version
        @extra = extra
      end

      def message
        "API Version #{api_version}: #{path} is not supported. #{extra}"
      end

      def status
        extra ? 410 : 404
      end
    end
  end
end