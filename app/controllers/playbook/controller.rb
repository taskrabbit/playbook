module Playbook
  module Controller
    extend ActiveSupport::Concern

    included do
      include ::Playbook::Integration
      include ::Playbook::Authorization
      include ::Playbook::Authentication
      include ::Playbook::ApiStandards

      rescue_from Exception,                        :with => :render_standard_error
      rescue_from ::Playbook::Errors::ObjectError,  :with => :render_object_error
      rescue_from ::ActiveRecord::RecordNotFound,   :with => :missing_action

      prepend_before_filter :load_session_if_needed
    end

    protected

    def load_session_if_needed
      session.send :load! unless session.loaded?
    end
  end
end