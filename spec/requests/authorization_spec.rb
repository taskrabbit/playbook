require 'spec_helper'

describe 'Playbook Authorization' do
  include Playbook::Spec::RequestHelper

  class PlaybookAuthorizationSpecController < Playbook::BaseController

    internal :internal_ep, :combined_ep
    interactive :interactive_ep, :combined_ep

    def none_ep
      head :ok
    end

    def internal_ep
      head :ok
    end

    def interactive_ep
      head :ok
    end

    def combined_ep
      head :ok
    end

  end

  it 'should fail when no client is passed and respond with a 401 unauthorized' do
    get '/api/v2/test/playbook_authorization_spec/none_ep.json', {}, {}
    error = get_error
    error['key'].should eql('request')
    error['message'].should eql('Client Application Required')
    response.status.should eql(412)
  end

  it 'should succeed when an application is provided' do
    authorize!(external_client_app)
    get '/api/v2/test/playbook_authorization_spec/none_ep.json', {}, headers
    response.status.should eql(200)
  end

  it 'should fail when a client app is provided but does not have the proper capabilities' do
    authorize!(external_client_app)
    get('/api/v2/test/playbook_authorization_spec/internal_ep.json', {}, headers)
    error = get_error
    error['key'].should eql('request')
    error['message'].should eql('NOT FOUND at /api/v2/test/playbook_authorization_spec/internal_ep.json')
    response.status.should eql(404)
  end

  it 'should succeed with the appropriate capabilities' do
    authorize!(internal_client_app)
    get '/api/v2/test/playbook_authorization_spec/internal_ep.json', {}, headers
    response.status.should eql(200)
  end

  it 'should fail when an internal app is provided but an interactive endpoint is required' do
    authorize!(internal_client_app)
    get('/api/v2/test/playbook_authorization_spec/interactive_ep.json', {}, headers)
    error = get_error
    error['key'].should eql('request')
    error['message'].should eql('NOT FOUND at /api/v2/test/playbook_authorization_spec/interactive_ep.json')
    response.status.should eql(404)
  end

  it 'should require both interactive and internal if they are both required' do
    interactive_client_app.stub(:internal?).and_return(false)
    authorize!(interactive_client_app)
    get('/api/v2/test/playbook_authorization_spec/combined_ep.json', {}, headers)
    error = get_error
    error['key'].should eql('request')
    error['message'].should eql('NOT FOUND at /api/v2/test/playbook_authorization_spec/combined_ep.json')
    response.status.should eql(404)
  end

  it 'should enable jsonp for all endpoints when an interactive app is present' do
    authorize!(interactive_client_app)
    get '/api/v2/test/playbook_authorization_spec/interactive_ep.jsonp', {'callback' => 'myfunc'}, headers
    response.status.should eql(200)
  end



end