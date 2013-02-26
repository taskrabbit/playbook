namespace :playbook do

  class EndpointDescription < Struct.new(:controller, :route)

    def deprecated?
      check_filter(:add_deprecation_header)
    end

    def auth_required?
      check_filter(:require_auth)
    end

    def internal?
      check_filter(:validate_internal_client_application)
    end

    def interactive?
      check_filter(:validate_interactive_client_application)
    end

    def unsupported?
      check_filter(:unsupport)
    end

    def jsonp?
      check_filter(:enable_jsonp)
    end

    def inspect(indent = 0)
      push = " " * indent
      out = []
      out << "#{push}#{self.path}"
      if unsupported?
        out << "#{push}  * UNSUPPORTED"
      else
        out << "#{push}  * DEPRECATED"              if deprecated?
        out << "#{push}  * requires authentication" if auth_required?
        out << "#{push}  * internal only"           if internal?
        out << "#{push}  * interactive only"        if interactive?
        out << "#{push}  * jsonp enabled"           if jsonp?
      end
      out.join("\n")
    end

    def path
      self.route.path.spec.to_s
    end

    protected

    def check_filter(filter_name)
      return false if controller_class.playbook_filters[filter_name].nil?

      controller_class.playbook_filters[filter_name].include?(self.action) ||
      controller_class.playbook_filters[filter_name].include?(:all)
    end

    def action
      @action ||= (self.route.defaults[:action] || 'unknown').to_sym
    end

    def controller_class
      @controller_class ||= "#{controller}_controller".classify.constantize
    end
  end


  task :describe, [:namespace, :grep] => :environment do |t, args|
    namespace = args[:namespace] || 'Playbook'
    grep      = args[:grep] ? /#{args[:grep]}/ : /.*/

    namespace = namespace.to_s.underscore
    matcher   = /^#{namespace}\//

    api_endpoints = Rails.application.routes.routes.to_a.map do |route|
      controller = route.defaults[:controller].to_s
      if controller =~ matcher
        endpoint = EndpointDescription.new(controller, route)
        endpoint.path =~ grep ? endpoint : nil
      else
        nil
      end
    end.compact

    api_groups = api_endpoints.group_by(&:controller)
    api_groups = api_groups.to_a.sort_by(&:first)
    
    api_groups.each do |group_name, endpoints|
      puts "\n#{group_name.classify}"
      endpoints.sort_by(&:path).each do |endpoint|
        puts endpoint.inspect(2)
      end
    end

  end 

end