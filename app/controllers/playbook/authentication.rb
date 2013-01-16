module Playbook
  module Authentication
    extend ActiveSupport::Concern

    included do
      helper_method :current_user
    end

    def current_user
      return @api_current_user if defined?(@api_current_user)

      user_id = oauth2_token.try(:user_id)
      user_id ||= get_user_id_from_session if current_client_application.try(:interactive?)

      @api_current_user = find_user_record(user_id) if user_id

      return @api_current_user = nil unless valid_api_user?(@api_current_user)

      @api_current_user
    end

    def get_user_id_from_session
      nil
    end

    def find_user_record(user_id)
      User.find(user_id) rescue nil
    end

    def valid_api_user?(user)
      !!user
    end

    def send_401_unauthorized
      error = ::Playbook::Errors::AuthenticationError.new(request.path)
      render_standard_error(error)
    end

    protected

    def require_auth
      raise ::Playbook::Errors::AuthenticationError.new(request.path) unless current_user
    end

    def oauth2_token
      return @oauth2_token if defined?(@oauth2_token)

      auth_token = oauth2_token_from_header
      auth_token ||= oauth2_token_from_params unless Rails.env.production?

      return @oauth2_token = nil unless auth_token
      @oauth2_token = find_oauth_token_by_secret(auth_token)
      return @oauth2_token = nil unless @oauth2_token.try(:authorized?)

      @oauth2_token
    end

    def find_oauth_token_by_secret(secret)
      token   = Oauth2Token.find_by_secret(secret) rescue nil
      token ||= OauthToken.find_by_secret(secret) rescue nil
      token
    end

    def oauth2_token_from_header
      request.headers['Authorization'].to_s =~ /^OAuth (.+)/
      $1.try(:strip)
    end

    unless Rails.env.production?
      def oauth2_token_from_params
        params[:oauth_token] || params[:access_token]
      end
    end

  end
end