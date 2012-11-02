require 'active_support/core_ext/object/try'

module Playbook
  class Matcher

    module ForModule
      LOOSE           = /(^|:)(V[1-9]+)(v[0-9]+)?(beta[\d]?)?($|:)/  # V1 || V1v2 || V1v2beta
      FULL            = /(^|:)(V[1-9]+v[0-9]+(beta[\d]?))($|:)/      # V1v2beta2
      MAJOR_AND_MINOR = /(^|:)(V[1-9]+v[0-9]+)($|:)/                 # V1v2
      MAJOR           = /(^|:)(V[1-9]+)($|:)/                        # V1
    end

    module ForVersion
      LOOSE           = /[Vv][1-9]+[Vv]?[0-9]+?(beta[\d]?)?/         # v1 || v1v2 || v1v2beta
      FULL            = /[Vv]([1-9]+)v([0-9]+)(beta[\d]?)/           # v1v2beta
      MAJOR_AND_MINOR = /[vV]([1-9]+)v([0-9]+)/                      # v1v2
      MAJOR           = /[vV]([1-9]+)/                               # v1

      STRING          = /^([\d]+)\.?([\d]+)?\.?(beta[\d]?)?$/        # 1 || 1.0 || 1.2 || 1.2.beta || 1.2.beta2
    end

    def version_module?(string)
      !!series_match(string, ForModule::LOOSE)
    end

    def version_string?(string)
      !!series_match(string, ForVersion::STRING)
    end

    def version_module_name(constant_name)
      matcher = series_match(constant_name, ForModule::FULL, ForModule::MAJOR_AND_MINOR, ForModule::MAJOR)
      matcher.try(:[], 2)
    end

    def version_from_namespace(constant_name)
      vname = version_module_name(constant_name)
      
      matchdata = series_match(vname, ForVersion::FULL, ForVersion::MAJOR_AND_MINOR, ForVersion::MAJOR)
      
      return nil unless matchdata

      major = matchdata[1]
      minor = matchdata[2]
      pre   = matchdata[3]

      ::Playbook::Version.new(major, minor, pre)
    end
    
    def namespace_from_version(version)
      ::Playbook::Version.for(version).to_namespace
    end

    # return the most relevant class based on the context and the requested name
    # context -> Api::V2::UsersController
    # name -> UserAdapter
    def most_relevant_constant(context, name, previous_only = false)

      this_version = ::Playbook::Version.for(context)
      prefix = context.name.split(this_version.to_namespace).first

      relevant_versions = ::Playbook.config.descending_versions(this_version, !this_version.beta?)
      relevant_versions -= [this_version] if previous_only

      relevant_versions.each do |v|

        klazz = begin
          "#{prefix}#{v.to_namespace}::#{name}".constantize
        rescue NameError => e
          nil
        end

        return klazz unless klazz.nil?
      end

      nil
    end
    alias_method :most_relevant_module, :most_relevant_constant
    alias_method :most_relevant_class,  :most_relevant_constant

    protected

    def series_match(string, *matchers)
      matchers.each do |matcher|
        if string.to_s =~ matcher
          return $~
        end 
      end
      nil
    end

  end
end