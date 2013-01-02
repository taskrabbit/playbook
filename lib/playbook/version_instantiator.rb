module Playbook
  module VersionInstantiator

    def const_missing(const_name)
      if Playbook::Matcher.version_module?(const_name)
        const_set(const_name, ::Playbook::VersionModule.new(self.name, const_name))
      else
        super
      end
    end


  end
end