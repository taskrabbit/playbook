require 'spec_helper'

describe ::Playbook::Controller do

  module Reptile
    extend ::Playbook::VersionInstantiator

    class V2::SnakeAdapter < ::Playbook::Adapter; end
    class V2::SnakesController < Struct.new(:params)
      include ::Playbook::Controller
    end

    class V2v1::ControllerRequest < ::Playbook::Request::ControllerRequest; end
    class V2v1::SnakesController < V2::SnakesController; end
  end

  before do
    ::Playbook.configure do
      register_versions 2, 2.1
    end
  end

  it 'should properly determine the adapter for the controller' do
    c = Reptile::V2::SnakesController.new({:param => 1})
    c.send(:playbook_adapter_class).should eql(Reptile::V2::SnakeAdapter)
    c.send(:playbook_request_class).should eql(::Playbook::Request::ControllerRequest)
    adapter = c.send(:adapter)
    adapter.should be_a(Reptile::V2::SnakeAdapter)
    adapter.params.should eql(:param => 1)
  end

  it 'should use the namespaced request class if it exists' do
    c = Reptile::V2v1::SnakesController.new({:param => 2})
    c.send(:playbook_adapter_class).should eql(Reptile::V2::SnakeAdapter)
    c.send(:playbook_request_class).should eql(Reptile::V2v1::ControllerRequest)
    adapter = c.send(:adapter)
    adapter.should be_a(Reptile::V2::SnakeAdapter)
    adapter.params.should eql(:param => 2)
  end

end