module Playbook
  class Version
    include Comparable

    def self.for(version)
      
      return version if version.is_a?(::Playbook::Version)

      result = nil

      version = version.name if version.is_a?(Class) || version.is_a?(Module)      
      
      if version.is_a?(String)
        if ::Playbook.matchers.version_string?(version)
          result = ::Playbook::Version.new(*version.split('.'))
        else
          result = ::Playbook.matchers.version_from_namespace(version) 
        end
      end
      
      result = ::Playbook::Version.new(version.to_f) if version.is_a?(Numeric)
      result
    end

    attr_reader :major, :minor, :beta

    def initialize(major = 1, minor = nil, beta = nil)

      beta = nil if beta == false

      if major.is_a?(Float) && minor.nil? && beta.nil?
        major, minor = major.to_s.split('.').map(&:to_i)
      end
      @major = major.to_i
      @minor = minor.to_i
      @beta = (beta == true ? 'beta' : beta)
    end

    def <=>(other)
      val = @major <=> other.major
      val = @minor <=> other.minor if val.zero?
      if val.zero?
        return 1 if !self.beta? && other.beta?
        return -1  if self.beta? && !other.beta?
        return @beta.to_s <=> other.beta.to_s 
      end
      val
    end

    def ==(other)
      other.to_s == self.to_s
    end
    alias_method :eql?, :==

    def hash
      self.to_s.hash
    end

    def major?
      @minor == 0 && !self.beta?
    end

    def beta?
      !!@beta
    end

    def to_namespace
      arr = array
      arr.map! do |v|
        if v.is_a?(Numeric)
          v.zero? ? nil : "v#{v}"
        else
         v.to_s
        end
      end
      arr.compact.join('').capitalize
    end

    def to_s
      array.join('.')
    end

    protected

    def array
      [@major, @minor, @beta].compact
    end
  end
end
