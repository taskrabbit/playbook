require 'spec_helper'

describe ::Playbook::BaseController do
  include Playbook::Spec::RequestHelper
  
  let(:user){ Playbook::User.find(1) }

  it 'should not use the current user from the session if no oauth user can be inferred and the current client app does not allow it' do    
    UserSession.should_receive(:find).never
    controller.stub(:current_client_application).and_return(internal_client_app)

    controller.current_user.should be_nil
  end

  it 'should use the current user from the session if no oauth user can be inferred and the current client app allows it' do
    controller.stub(:current_client_application).and_return(interactive_client_app)
    controller.stub(:get_user_id_from_session).and_return(user.id)
    
    controller.current_user.should eql(user)
  end

  it 'should infer both the client app and the user from the oauth2 token' do
    tok!(external_client_app, user)

    controller.current_user.should eql(user)
    controller.current_client_application.should eql(external_client_app)
  end

  it 'should define endpoints on the fly for adapters' do
    controller.stub(:test) # weird rspec issue: undefined method `__rspec_original_dup' for class `AuthTestController'
    controller.should_not respond_to(:my_test_case_adapter_function)
    controller.class_eval do
      forward_to_adapter :my_test_case_adapter_function, :head => :ok
    end
    controller.should respond_to(:my_test_case_adapter_function)
  end

  it 'should accept both Bearer and OAuth headers' do
    request = stub(:headers => {'Authorization' => 'Bearer 6b08ed8569af5466307897ca9386f9706c830a52'})
    controller.stub(:request).and_return(request)
    controller.send(:oauth2_token_from_header).should eql('6b08ed8569af5466307897ca9386f9706c830a52')
  end

  context 'jsonp' do

    it 'should raise an error when jsonp is attempted on an endpoint that doens\'t allow it' do
      controller.stub(:params).and_return({:format => 'jsonp'})
      controller.stub(:jsonp_enabled?).and_return(false)
      controller.should be_jsonp_attempt
      controller.should_not be_valid_jsonp
      lambda{
        controller.send(:verify_jsonp_validity)
      }.should raise_error('Jsonp is not enabled for this endpoint.')
    end

    it 'should raise an error with feedback about the missing callback' do
      controller.stub(:params).and_return({:format => 'jsonp'})
      controller.stub(:jsonp_enabled?).and_return(true)
      controller.should be_jsonp_attempt
      controller.should_not be_valid_jsonp
      lambda{
        controller.send(:verify_jsonp_validity)
      }.should raise_error('Invalid jsonp request. Provide a callback parameter.')
    end

    it 'should not raise an error when everything is wonderful' do
      controller.stub(:params).and_return({:format => 'jsonp', :callback => 'mytestfunction'})
      controller.stub(:jsonp_enabled?).and_return(true)
      controller.should be_jsonp_attempt
      controller.should be_valid_jsonp
      lambda{
        controller.send(:verify_jsonp_validity)
      }.should_not raise_error
    end
  end


  protected

  def tok!(app, user)
    token = Playbook::Oauth2Token.new
    token.stub(:client_application).and_return(app)
    token.stub(:user_id).and_return(user.id)
    controller.stub(:oauth2_token).and_return(token)
  end
end