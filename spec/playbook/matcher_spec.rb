require 'spec_helper'

describe Playbook::Matcher do

  let(:matcher){ Playbook::Matcher }

  %w(V2 V2v1 V2v2beta).each do |v|
    it "should determine #{v} style version modules correctly" do
      matcher.version_module?(v).should be_true
    end
  end

  %w(v1 Mod V2v1pre).each do |v|
    it "should determine #{v} is not a version module" do
      matcher.version_module?(v).should be_false
    end
  end

  %w(2 2.1 2.0 5.2 5.0.beta 5.5.beta1).each do |v|
    it "should determine version Strings like #{v} correctly" do
      matcher.version_string?(v).should be_true
    end
  end

  %w(a 2.a four).each do |v|
    it "should determine Strings like #{v} are not version Strings" do
      matcher.version_string?(v).should be_false
    end
  end

  %w(Api::V2::Controller Api::V1v5::Controller Api::Submodule::V2v1beta1).each do |full_name|
    it "should pull out the version module name from a larger constant (#{full_name})" do
      vname = full_name.split('::').select{|s| s =~ /^V/}.first
      matcher.version_module_name(full_name).should eql(vname)
    end
  end

  %w(Api::Controller User Api::Submodule::Va).each do |full_name|
    it "should not pull out a version module name from a larger constant like #{full_name}" do
      matcher.version_module_name(full_name).should be_nil
    end
  end

  %w(Api::V2::Controller Api::V1v5::Controller Api::Submodule::V2v1beta1).each do |full_name|
    it "should pull out the version number from a constant name (#{full_name})" do
      vname = full_name.split('::').select{|s| s =~ /^V/}.first
      major = vname[1..1].to_i
      minor = vname[3..3].to_i
      beta  = vname[4..-1].to_s
      beta = nil if beta.empty?
      version_name = [major, minor, beta].compact.join('.')
      matcher.version_from_namespace(full_name).should eql(version_name)
    end
  end

  it 'should not pull out a version number if it can\'t figure it out' do
    matcher.version_from_namespace('TestClass::Version::Whatever').should be_nil
  end

  context '#most_relevant_constant' do

    module Dog
      extend ::Playbook::VersionInstantiator
    end

    class Dog::V1::Context; end
    class Dog::V1::CanineAdapter; end
    class Dog::V1v5beta::CanineAdapter; end
    class Dog::V1v5::Context; end
    class Dog::V2::Context; end
    class Dog::V2::CanineAdapter; end
    class Dog::V2v2::Context; end

    module Cat
      extend ::Playbook::VersionInstantiator
    end

    class Cat::V1::Context; end
    class Cat::V1::FelineAdapter; end

    before do
      Playbook.configure do |c|
        c.register_version 1, 1.1, 2, 2.2
      end
    end

    it 'should return back the most relevant class given a direct match' do
      matcher.most_relevant_constant(Dog::V1::Context, 'CanineAdapter').should eql(Dog::V1::CanineAdapter)
      matcher.most_relevant_constant(Cat::V1::Context, 'FelineAdapter').should eql(Cat::V1::FelineAdapter)
      matcher.most_relevant_constant(Cat::V1::Context, 'CanineAdapter').should be_nil
    end

    it 'should return back the most relevant previous version when a direct match doesnt exist' do
      matcher.most_relevant_constant(Dog::V1v5::Context, 'CanineAdapter').should eql(Dog::V1::CanineAdapter)
    end

    it 'should return back the previous match when asked to' do
      matcher.most_relevant_constant(Dog::V2::Context, 'CanineAdapter', true).should eql(Dog::V1::CanineAdapter)
    end

    it 'should ignore beta versions when guessing a previous constant' do
      matcher.most_relevant_constant(Dog::V1v5::Context, 'CanineAdapter').should eql(Dog::V1::CanineAdapter)
      matcher.most_relevant_constant(Dog::V1v5::Context, 'CanineAdapter', true).should eql(Dog::V1::CanineAdapter)
    end

  end
end