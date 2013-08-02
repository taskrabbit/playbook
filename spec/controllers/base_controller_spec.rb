require 'spec_helper'

class BaseController < ActionController::Base
  include Playbook::Controller
end

describe BaseController do
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

  it 'should accept Bearer as header' do
    request = stub(:headers => {'Authorization' => 'Bearer 6b08ed8569af5466307897ca9386f9706c830a52'})
    controller.stub(:request).and_return(request)
    controller.send(:oauth2_token_from_header).should eql('6b08ed8569af5466307897ca9386f9706c830a52')
  end

  it 'should accept OAuth as header' do
    request = stub(:headers => {'Authorization' => 'OAuth 6b08ed8569af5466307897ca9386f9706c830a52'})
    controller.stub(:request).and_return(request)
    controller.send(:oauth2_token_from_header).should eql('6b08ed8569af5466307897ca9386f9706c830a52')
  end

  protected

  def tok!(app, user)
    token = Playbook::Oauth2Token.new
    token.stub(:client_application).and_return(app)
    token.stub(:user_id).and_return(user.id)
    controller.stub(:oauth2_token).and_return(token)
  end
end