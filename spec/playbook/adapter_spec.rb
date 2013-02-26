require 'spec_helper'

describe ::Playbook::Adapter do

  module Whale
    extend ::Playbook::VersionInstantiator

    class V2::Adapter < ::Playbook::Adapter

      whitelist :object, :on => :doit 
      require_params :id, :on => :doit

      whitelist :something, :on => :doit3
      whitelist :all,       :on => :doit3

      def doit
        success({:name => :doit, :params => self.params})
      end

      def doit2
        success({:name => :doit2, :params => self.params})
      end

      def doit3
        success({:name => :doit3, :params => self.params})
      end

    end

    class V2v1::Adapter < V2::Adapter

      def doit
        success({:name => :doit, :params => self.params.merge(:v2v1 => true)})
      end

      def doit2
        success({:name => :doit2, :params => self.params.merge(:v2v1 => true)})
      end

      def doit3
        failure({:name => :doit3, :params => self.params.merge(:v2v1 => true)})
        invoking_a_method_that_doesnt_exist
      end
    end

    class V3::Adapter < ::Playbook::Adapter

      require_params :id, :on => :all
      require_params :user_id, :on => :doit

      def doit
        success(:name => :doit, :params => self.params.merge(:v2require => true))
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

  it 'should be able to require params' do
    a = adapter('V2', {:anything => true})
    lambda{
      a.doit
    }.should raise_error(Playbook::Errors::RequiredParameterMissingError)
  end

  it 'should allow any paramater through if all is provided in the whitelist' do
    a = adapter('V2', {:email => true})
    a.doit3.should be_success

    a = adapter('V2', {:id => true})
    a.doit3.should be_success

    a = adapter('V2', {:jibberish => 'delta'})
    a.doit3.should be_success
  end

  it 'should exit the method execution immediately when success or failure is called' do
    a  = adapter('V2v1', {:id => true})
    lambda{
      a.doit3.should_not be_success
    }.should_not raise_error
  end

  it 'should require the all params and the method params' do
    a = adapter('V3', {:id => true})
    lambda{
      a.doit.should_not be_success
    }.should raise_error(/user_id/)

    b = adapter('V3', {:user_id => true})
    lambda{
      b.doit.should_not be_success
    }.should raise_error(/ id/)

    c = adapter('V3', {:id => true, :user_id => true})
    lambda{
      c.doit.should be_success
    }.should_not raise_error
  end
end