require 'spec_helper'

describe 'Playbook Authentication Spec' do
  include Playbook::Spec::RequestHelper


  class AuthTestController < Playbook::BaseController

    require_auth :auth_required_ep

    def auth_required_ep
      render '/empty'
    end

  end

  let(:user){ Playbook::User.find(1) }

  before do
    authorize!(external_client_app)
  end

  it 'should provide an authentication error when no user is present' do
    get('/api/v2/test/auth_test/auth_required_ep.json', {}, headers)
    error = get_error
    response.status.should eql(401)
    error['key'].should eql('request')
    error['message'].should eql("/api/v2/test/auth_test/auth_required_ep.json requires authentication")
  end

  context 'via an oauth token' do

    before do 
      authenticate!(user, internal_client_app)
    end

    it 'should provide the user to the controller via the oauth token' do
      info = get_request_info '/api/v2/test/auth_test/auth_required_ep.json', {}, headers
      info['current_user_id'].should eql(user.id)
    end

    it 'should provide the client app to the controller with presedence over the passed client app' do
      info = get_request_info '/api/v2/test/auth_test/auth_required_ep.json', {}, headers
      info['client_application_id'].should eql(internal_client_app.id)
    end

  end

  context 'via an interactive session' do

    before do
      authorize!(nil)
      authenticate_via_session!(user)
    end

    it 'should find the user via the session' do
      info = get_request_info '/api/v2/test/auth_test/auth_required_ep.json', {}, headers
      info['current_user_id'].should eql(user.id)
      info['client_application_id'].should eql(interactive_client_app.id)
    end

  end

end