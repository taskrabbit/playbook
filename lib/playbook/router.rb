module Playbook
  module Router

    def version(*versions)
      options = versions.extract_options!
      versions = ::Playbook.config.descending_versions if versions == [:all]
      versions = versions.map{|v| ::Playbook.matchers.namespace_from_version(v).downcase }
      versions.each do |v|
        namespace v, options.clone do
          instance_eval{ yield }
        end
      end
    end
    alias_method :versions, :version

  end
end