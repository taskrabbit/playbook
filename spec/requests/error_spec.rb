require 'spec_helper'

describe "Playbook Errors" do
  include Playbook::Spec::RequestHelper

  class ErrorObject
    def add(name, msg)
      @errors ||= {}
      @errors[name] ||= []
      @errors[name] << msg
      @errors
    end

    def errors
      @errors || {}
    end

    def id
      'fake'
    end

    def self.human_attribute_name(key)
      key.to_s.humanize.capitalize
    end
  end

  class PlaybookErrorSpecController < Playbook::BaseController

    require_auth  :auth_ep
    require_admin :admin_ep
    internal      :internal_ep
    jsonp_enabled :jsonp_ep

    def general_error
      raise "Anything"
    end

    def object_error
      obj = ErrorObject.new
      obj.add(:name, 'cant be blank')
      raise ::Playbook::Errors::ObjectError.new(obj)
    end

    def jsonp_ep
      head :ok
    end

    def auth_ep
      head :ok
    end

    def admin_ep
      head :ok
    end

    def internal_ep
      head :ok
    end

    def happy
      head :ok
    end

    def api_version
      @api_version ||= ::Playbook::Version.for('2.0')
    end

  end

  it 'should provide back request information when an error occurs' do
    get '/api/v2/test/playbook_error_spec/happy.json'
    json = JSON.parse(response.body)

    json['request']['path'].should eql('/api/v2/test/playbook_error_spec/happy.json')
    json['request']['api_version'].should eql('2.0')
  end

  it 'should blow up due to a client app and provide a meaningful error' do
    get '/api/v2/test/playbook_error_spec/happy.json'
    error = get_error
    error['key'].should eql('request')
    error['message'].should eql('Client Application Required')
  end

  context 'with a client app' do

    before do
      authorize!(external_client_app)
    end

    it 'should not have any issues with the happy path' do
      get '/api/v2/test/playbook_error_spec/happy.json', {}, headers
      response.status.should eql(200)
    end

    it 'should provide back the message of a general error' do
      get('/api/v2/test/playbook_error_spec/general_error.json', {}, headers)
      error = get_error
      error['key'].should eql('request')
      error['message'].should eql('Anything')
    end

    it 'should render object errors for AR\'s' do
      get('/api/v2/test/playbook_error_spec/object_error.json', {}, headers)
      error = get_error

      error['key'].should eql('name')
      error['message'].should eql('Name cant be blank')
    end

    context 'authentication' do

      it 'should require authentication' do
        get('/api/v2/test/playbook_error_spec/auth_ep.json', {}, headers)
        error = get_error
        error['key'].should eql('request')
        error['message'].should match(/requires authentication/)
      end

      it 'should succeed with an authenticated user' do
        authenticate!(Playbook::User.find(1))
        get '/api/v2/test/playbook_error_spec/auth_ep.json', {}, headers
      end
    end

    context 'administration' do

      it 'should require an admin' do
        get '/api/v2/test/playbook_error_spec/admin_ep.json', {}, headers
        response.status.should eql(401)

        error = get_error
        error['key'].should eql('request')
        error['message'].should match(/Only admins can access/)
      end

      it 'should allow access to someone with an admin role' do
        authenticate!(Playbook::User.find(1))
        Playbook::User.any_instance.stub(:admin).and_return(true)
        get '/api/v2/test/playbook_error_spec/admin_ep.json', {}, headers
        response.status.should eql(200)
      end

    end

    context 'authorization' do

      it 'should require an internal app' do
        get('/api/v2/test/playbook_error_spec/internal_ep.json', {}, headers)
        error = get_error
        response.status.should eql(404)
      end

      it 'should be successful with an internal app' do
        authorize!(internal_client_app)
        get '/api/v2/test/playbook_error_spec/internal_ep.json', {}, headers
        response.status.should eql(200)
      end
    end

    context 'jsonp' do

      it 'should 404 if the endpoint does not allow jsonp' do
        get('/api/v2/test/playbook_error_spec/happy.jsonp', {}, headers)
        error = get_error
        response.status.should eql(405)
        error['key'].should eql('request')
        error['message'].should eql('Jsonp is not enabled for this endpoint.')
      end

      it 'should require a callback param' do
        get('/api/v2/test/playbook_error_spec/jsonp_ep.jsonp', {}, headers)
        error = get_error
        response.status.should eql(400)
        error['key'].should eql('request')
        error['message'].should eql('Invalid jsonp request. Provide a callback parameter.')
      end

      it 'should work with enabled and the callback provided' do
        get '/api/v2/test/playbook_error_spec/jsonp_ep.json', {'callback' => 'myfunc'}, headers
        response.status.should eql(200)
      end

      it 'should allow jsonp on all endpoints for interactive apps' do
        authorize!(interactive_client_app)
        get '/api/v2/test/playbook_error_spec/happy.jsonp', {'callback' => 'myfunc'}, headers
        response.status.should eql(200)
      end

    end
  end

end