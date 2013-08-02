require 'playbook/gem_version'
require 'playbook/engine' if defined?(Rails)

module Playbook

  autoload :Adapter,                    'playbook/adapter'
  autoload :Configuration,              'playbook/configuration'
  autoload :Engine,                     'playbook/engine'
  autoload :Errors,                     'playbook/errors'
  autoload :Integration,                'playbook/integration'
  autoload :Jbuilder,                   'playbook/jbuilder'
  autoload :JsonResult,                 'playbook/json_result'
  autoload :Matcher,                    'playbook/matcher'
  autoload :Router,                     'playbook/router'
  autoload :VersionModule,              'playbook/version_module'
  autoload :Version,                    'playbook/version'
  autoload :VersionInstantiator,        'playbook/version_instantiator'

  module Request
    autoload :BaseRequest,              'playbook/request/base_request'
    autoload :ControllerRequest,        'playbook/request/controller_request'
  end

  module Response
    autoload :BaseResponse,             'playbook/response/base_response'
    autoload :ControllerResponse,       'playbook/response/controller_response'
    autoload :BaseErrorResponse,        'playbook/response/base_error_response'
    autoload :ControllerErrorResponse,  'playbook/response/controller_error_response'
  end

  module Spec
    autoload :RequestHelper,            'playbook/spec/request_helper'
  end


  class << self

    def play!(module_name)
      mod   = nil
      mod   = module_name if module_name.is_a?(Module)
      mod ||= Object.const_set(module_name, Module.new) unless Object.const_defined?(module_name)
      mod ||= module_name.to_s.constantize

      mod.send(mod.is_a?(Module) ? :module_eval : :class_eval) do
        extend VersionInstantiator

        class << self
          
          def configure
            yield ::Playbook::Configuration.instance if block_given?
            ::Playbook::Configuration.instance
          end
          alias_method :config, :configure

        end
      end

      mod
    end

  end
  
end