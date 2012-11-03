require 'spec_helper'

describe Playbook::VersionInstantiator do

  class Feather; end

  module Bird
    extend ::Playbook::VersionInstantiator
  
    class V1::Feather; end
    class V1v0beta::Feather; end
    class V2::Feather; end
  end

  before do
    ::Playbook.configure do
      register_version 1, 2
    end
  end

  # makes sure the root level constant doesn't take priority
  before do
    f = Feather.new
  end

  it 'should build constants automatically, based on the registered playbook versions' do
    Bird::V1v1::Feather.should eql(Bird::V1::Feather)
    Bird::V2v5::Feather.should eql(Bird::V2::Feather)
  end

  it 'should raise errors like normal for truly missing constants' do
    lambda{
      Bird::V0v1::Feather
    }.should raise_error(NameError)

    lambda{
      Bird::V1::Talon
    }.should raise_error(NameError)

    lambda{
      Bird::V2v3::Talon
    }.should raise_error(NameError)
  end


end