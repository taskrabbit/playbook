require 'playbook/gem_version'

module Playbook

  autoload :Adapter,              'playbook/adapter'
  autoload :Configuration,        'playbook/configuration'
  autoload :Controller,           'playbook/controller'
  autoload :Errors,               'playbook/errors'
  autoload :Matcher,              'playbook/matcher'
  autoload :Router,               'playbook/router'
  autoload :VersionModule,        'playbook/version_module'
  autoload :KeyGen,               'playbook/key_gen'
  autoload :Throttler,            'playbook/throttler'
  autoload :Version,              'playbook/version'
  autoload :VersionInstantiator,  'playbook/version_instantiator'

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