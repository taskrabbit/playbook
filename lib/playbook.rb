require 'playbook/gem_version'

module Playbook

  autoload :Adapter,                    'playbook/adapter'
  autoload :Configuration,              'playbook/configuration'
  autoload :Controller,                 'playbook/controller'
  autoload :Errors,                     'playbook/errors'
  autoload :Matcher,                    'playbook/matcher'
  autoload :Router,                     'playbook/router'
  autoload :VersionModule,              'playbook/version_module'
  autoload :KeyGen,                     'playbook/key_gen'
  autoload :Throttler,                  'playbook/throttler'
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
    autoload :ControllerErrorResponse,  'playbook/response/base_response'
  end


  class << self
    

    def configure(&block)
      @configuration ||= ::Playbook::Configuration.new
      @configuration.instance_eval(&block) if block_given?
      @configuration
    end
    alias_method :config, :configure


    def matchers
      @matchers ||= ::Playbook::Matcher.new
    end
    alias_method :matcher, :matchers

  end
     
end