require 'active_support/dependencies'

class Module
  def playbook_version
    nil
  end
end

module Playbook
  class VersionModule < Module
    unloadable

    def initialize(parent_name, name)
      @parent_name = parent_name
      @name = name
    end

    def name
      "#{@parent_name}::#{@name}"
    end
    alias_method :to_s, :name
    alias_method :inspect, :name

    def playbook_version
      @playbook_version ||= Playbook.matchers.version_from_namespace(self.name)
    end

    def const_missing(const_name)

      error = nil

      klazz = begin
        super 
      rescue Exception => e
        error = e
        nil
      end

      return klazz if klazz.to_s =~ /^#{self.name}::/

      klazz2 = ::Playbook.matchers.most_relevant_constant(self, const_name, true)

      return const_set(const_name, klazz2) if klazz2

      return klazz if klazz
      
      raise error || NameError.new("Unkown constant name #{const_name}")

    end

  end
end