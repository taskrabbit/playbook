module Playbook::ApiStandards
  extend ActiveSupport::Concern

  included do
    layout '/playbook/layouts/application.json'

    helper_method :api_version, :jsonp?, :jsonp_enabled?, :top_level_content, :api_request_params

    before_filter :verify_jsonp_validity
    before_filter :determine_requested_response_format

    prepend_before_filter :set_request_start
  end

  module ClassMethods

    def playbook_filters
      @playbook_filters ||= {}
    end

    protected

    def forward_to_adapter(*methods)
      options = methods.extract_options!
      methods.each do |m|

        render = nil
        head = nil
        if options[:render]
          render = "render #{options[:render].inspect}"
          render << ", :status => #{options[:status].inspect}" if options[:status]
        elsif options[:head]
          head = "head #{options[:head].inspect}"
        end

        class_eval <<-EV, __FILE__, __LINE__+1
          def #{m}
            @response = adapter.#{m}
            #{render if render}
            #{head if head}
          end
        EV
      end
    end

    def require_auth(*methods)
      before_filter_with_or_without_methods :require_auth, methods
    end

    def require_admin(*methods)
      before_filter_with_or_without_methods :require_admin, methods
    end

    def internal(*methods)
      before_filter_with_or_without_methods :validate_internal_client_application, methods
    end

    def interactive(*methods)
      before_filter_with_or_without_methods :validate_interactive_client_application, methods
    end

    def jsonp_enabled(*methods)
      before_filter_with_or_without_methods :enable_jsonp, methods, :prepend
    end

    def deprecate(*methods)
      before_filter_with_or_without_methods :add_deprecation_header, methods
    end

    def no_longer_supported(*methods)
      before_filter_with_or_without_methods :unsupport, methods
    end

    def debug(*methods)
      before_filter_with_or_without_methods :debug, methods
    end


    protected

    def before_filter_with_or_without_methods(name, methods, filter_prefix = nil)
      filter = [filter_prefix, :before_filter].compact.join('_')
      
      self.playbook_filters[name] ||= []

      if methods.empty? || methods.include?(:all)
        self.playbook_filters[name] |= [:all]
        send(filter, name)
      else
        self.playbook_filters[name] |= methods
        send(filter, name, :only => methods)
      end
    end

  end

  def missing_action
    params[:format] ||= 'json'
    path   = [*params[:path]].compact.join('/') if params[:path]
    path ||= request.path
      
    error = ::Playbook::Errors::EndpointNotSupportedError.new(path, api_version, nil)
    render_standard_error(error)
  end

  protected

  def api_request_params
    computation_time  = @request_start_time ? ((Time.now.utc.usec/1000.0) - @request_start_time).to_i : nil
    
    {
      :server_time => Time.now.to_i, 
      :api_version => api_version.to_s, 
      :computation_time => computation_time,
      :current_user_id => current_user.try(:id),
      :client_application_id => current_client_application.try(:id),
      :path => request.path,
      :params => params.except(:action, :controller, :format)
    }
  end

  def set_request_start
    @request_start_time = Time.now.utc.usec / 1000.0
  end
  

  def debug
    debugger
    a=1
  end



  #### api versioning ####

  def add_deprecation_header
    response.headers['X-Endpoint-Deprecation-Warning'] = "This api endpoint is now deprecated. Please refer to the documentation."
  end

  def unsupport
    raise ::Playbook::Errors::EndpointNotSupportedError.new(request.path, api_version, "Use the previous api version to access this endpoint.")
  end


  #### jsonp support ###

  def enable_jsonp
    @jsonp_enabled = true
  end

  def valid_jsonp?
    jsonp_attempt? && params[:callback].present?
  end
  alias_method :jsonp?, :valid_jsonp?

  def jsonp_enabled?
    @jsonp_enabled || current_client_application.try(:interactive)
  end

  def jsonp_attempt?
    params[:format] == 'jsonp'
  end

  def verify_jsonp_validity
    if jsonp_attempt?
      if !jsonp_enabled?
        raise ::Playbook::Errors::EndpointNotSupportedError.new(request.path, api_version, "Jsonp is not enabled for this endpoint.", 405)
      elsif !valid_jsonp?
        raise ::Playbook::Errors::EndpointNotSupportedError.new(request.path, api_version, "Invalid jsonp request. Provide a callback parameter.", 400)
      end
    end
  end


  ##### response formatting #####

  def determine_requested_response_format
    @respond_with_head = !!(params.delete(:head).to_s =~ /^1|true$/)
  end

  def respond_with_head?
    !!@respond_with_head
  end

  def render(*args)
    if respond_with_head?
      options = args.extract_options!
      status  = options[:status] || 200
      head status
    else
      super
    end
  end

  def render_object_error(error)
    @error_object = error
    render '/playbook/layouts/active_record_error', :status => error.respond_to?(:status) ? error.status : 422
  end

  def render_standard_error(error)
    @error_object = error
    render '/playbook/layouts/error', :status => error.respond_to?(:status) ? error.status : 500
  end

end