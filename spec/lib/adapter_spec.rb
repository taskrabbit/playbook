require 'spec_helper'

describe ::Playbook::Adapter do

  module Whale
    extend ::Playbook::VersionInstantiator

    class V2::Adapter < ::Playbook::Adapter

      whitelist :object, :on => :doit 
      require_params :id, :on => :doit

      def doit
        success({:name => :doit, :params => self.params})
      end

      def doit2
        success({:name => :doit2, :params => self.params})
      end

    end

    class V2v1::Adapter < V2::Adapter

      def doit
        success({:name => :doit, :params => self.params.merge(:v2v1 => true)})
      end

      def doit2
        success({:name => :doit2, :params => self.params.merge(:v2v1 => true)})
      end
    end
  end

  def adapter(version, params = {})
    request = ::Playbook::Request::BaseRequest.new(params)
    "Whale::#{version}::Adapter".constantize.new(request)
  end

  it 'should filter out unwanted params if mentioned' do
    a = adapter('V2', {:id => 'test', :bad => true})
    response = a.doit
    response.params.should eql(:id => 'test')
  end 

end