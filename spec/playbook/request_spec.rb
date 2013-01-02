require 'spec_helper'

describe 'Requests' do

  class Controller

    def current_user
      'My User'
    end

    def params
      {
        :action => 'test',
        :controller => 'test_controller',
        :format => 'json',
        :id => 44,
        :field => 'value'
      }
    end
  end

  context "Controller Requests" do

    let(:controller){ Controller.new }
    let(:request){ ::Playbook::Request::ControllerRequest.new(controller)}

    it 'should grab the controller params but leave out the controller, action, and format' do
      request.params.should eql({:id => 44, :field => 'value'})
    end

    it 'should return the same controller back' do
      request.controller.object_id.should eql(controller.object_id)
    end

  end

end