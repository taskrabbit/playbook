require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/class/attribute'

module Playbook
  class Adapter  
    
    class FinishedNotifier < StandardError; end

    delegate :params, :current_user, :current_client_application, :to => :@request

    def initialize(request)
      @response = nil
      @request = request
    end

    def success(variables = {})
      respond(true, variables)
    end

    def failure(object_or_message = nil)
      respond(false, object_or_message)
    end

    def respond(success, variables_or_message, skip_raise = false)
      if success
        @response = @request.response_class.new(@request, true, variables_or_message)
      else
        @response = @request.error_response_class.new(@request, false, variables_or_message)
      end  
      raise FinishedNotifier unless skip_raise
    end


    class << self
      
      def whitelist(*keys)
        options = keys.extract_options!

        on = [options[:on] || options[:for] || :all].flatten.compact

        on.each do |key|
          whitelisted_params[key] ||= []
          whitelisted_params[key] |= keys
        end
      end

      def require_params(*keys)
        whitelist(*keys)

        options = keys.extract_options!

        on = [options[:on] || options[:for] || :all].flatten.compact
        
        on.each do |key|
          required_params[key] ||= []
          required_params[key] |= keys
        end
      end
      alias_method :require_param, :require_params

      def sanitize_params!(instance, method_name)
        safe_keys = Array(whitelisted_params[method_name.to_sym]) 
        return if safe_keys.include?(:all)

        safe_keys |= Array(whitelisted_params[:all])
        return if safe_keys.empty? || safe_keys.include?(:all)

        instance.params.slice!(*safe_keys)
      end

      # TODO: refactor. creates a lot of extra arrays and stuff.
      def ensure_required_params_exist!(instance, method_name)

        required_keys   = Array(required_params[method_name.to_sym])
        required_keys  |= Array(required_params[:all])

        return if required_keys.empty?
        
        param_keys = instance.params.keys.map(&:to_sym)

        unless required_keys.empty?
          missing_required = (required_keys - param_keys)
          raise ::Playbook::Errors::RequiredParameterMissingError.new(missing_required) unless missing_required.empty?
        end
    
      end
      
      def whitelisted_params
        @whitelisted_params ||= {}
      end
      
      def whitelisted_params=(params)
        @whitelisted_params = params
      end

      def required_params
        @required_params ||= {}
      end
      
      def required_params=(params)
        @required_params = params
      end

      # do this at the end so only methods declared from this point on are observed
      def method_added(method_name)
        return if @skip_method_checking
        return if method_name.to_s =~ /_with(out)?_filters$/
        return unless self.public_instance_methods.include?(method_name.to_sym) || self.public_instance_methods.include?(method_name.to_s)
        endpoint(method_name)
      end

      protected

      def endpoint(name, options = {}, &block)

        without_method_checks do
          class_eval <<-SAN, __FILE__, __LINE__ + 1
            def #{name}_with_filters(*args)
              self.class.ensure_required_params_exist!(self, '#{name}')
              self.class.sanitize_params!(self, '#{name}')
              begin
                #{name}_without_filters(*args)
              rescue ::Playbook::Adapter::FinishedNotifier => e
                raise ::Playbook::Errors::ResponseNotProvidedError.new(self, '#{name}') unless @response
              end

              @response ||= respond(true, {}, true)
        
              @response
            end
          SAN
          alias_method_chain name, :filters
        end
      end

      # this is needed because confusing things happen and you end up with a stack level too deep.
      # stack level too deeps aren't cool and stuff.
      def without_method_checks
        @skip_method_checking = true
        yield
        @skip_method_checking = false
      end

    end
  end
end