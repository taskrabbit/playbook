class Playbook::BaseController < ActionController::Base
  include ::Playbook::Controller
  include ::Playbook::Authorization
  include ::Playbook::Authentication
  include ::Playbook::ApiStandards

  rescue_from Exception,                        :with => :render_standard_error
  rescue_from ::Playbook::Errors::ObjectError,  :with => :render_object_error
  rescue_from ::ActiveRecord::RecordNotFound,   :with => :missing_action

  prepend_before_filter :load_session_if_needed


  def redirect_or_render_api_request(path, options = {})
    if should_render_api_redirect_request?
      @url = path
      Rails.logger.info "[Playbook] Rendered instead of redirecting: #{@url}"
      begin
        @json = JSON.parse(open(@url).read)
        render '/playbook/layouts/redirect', :layout => false
      rescue Exception => e
        raise "#{@url}: #{e.message}"
      end

    else
      redirect_to path, options
    end
  end


  protected

  def should_render_api_redirect_request?
    Rails.env.test?
  end

  def load_session_if_needed
    session.send :load! unless session.loaded?
  end
end