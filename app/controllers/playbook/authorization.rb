module Playbook::Authorization
  extend ActiveSupport::Concern

  included do
    before_filter :validate_client_application
    after_filter  :append_client_header
  end

  def current_client_application
    return @current_client_application if defined?(@current_client_application)

    @current_client_application = oauth2_token.try(:client_application)
    @current_client_application ||= begin
      client_token = retrieve_client_token
      client_token ? find_client_application_record(client_token) : nil
    end

    @current_client_application
  end

  protected

  def find_client_application_record(secret)
    defined?(ClientApplication) ? ClientApplication.find_by_secret(secret) : nil
  end

  def validate_internal_client_application
    missing_action unless current_client_application.try(:internal?)
  end

  def validate_interactive_client_application
    missing_action unless current_client_application.try(:interactive?)
  end

  def validate_client_application
    raise ::Playbook::Errors::AccessNotGrantedError.new('Client Application Required') unless current_client_application
  end

  def append_client_header
    response.headers['X-Client-Application'] = client_token_from_headers
    response.headers['X-TR-App'] = client_token_prefix_from_headers
  end

  def retrieve_client_token
    token   = client_token_from_headers
    token ||= client_token_from_params    unless Rails.env.production?
    token ||= client_token_from_session
  end

  def client_token_from_headers
    request.headers['X-Client-Application']
  end

  def client_token_prefix_from_headers
    request.headers['X-TR-App']
  end

  def client_token_from_session
    prefix = client_token_prefix_from_headers
    return nil unless prefix

    token = session[:"#{prefix}_client"]
    find_client_application_record(token).try(:internal?) ? token : nil
  end

  unless Rails.env.production?
    def client_token_from_params
      params[:auth_token]
    end
  end
end