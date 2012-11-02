require 'spec_helper'

describe ::Playbook::Version do

  def v(*args)
    ::Playbook::Version.new(*args)
  end

  def f(*args)
    ::Playbook::Version.for(*args)
  end

  module Moose
    extend ::Playbook::VersionInstantiator
    class V2v1::Leg; end
  end

  it 'should create a version based on many different inputs' do
    v(3).should           eql('3.0')
    v(3, 4).should        eql('3.4')
    v(3, 4, true).should  eql('3.4.beta')
    v(3, 4, false).should eql('3.4')
    v(3.45).should        eql('3.45')
  end

  it 'should build versions from many different things' do
    f(3).should                 eql('3.0')
    f(3.4).should               eql('3.4')
    f('3.4').should             eql('3.4')
    f('3.4.beta2').should       eql('3.4.beta2')
    f('V2').should              eql('2.0')
    f('V2v1').should            eql('2.1')
    f('V2v1beta5').should       eql('2.1.beta5')
    f(Moose::V2v1).should       eql('2.1')
    f(Moose::V2v1::Leg).should  eql('2.1')
    f(Moose).should             be_nil
  end

  it 'should compare properly' do
    f(3).should                 < f(4)
    f(3.4).should               < f(4)
    f('3.4.beta').should        < f(3.4)
    f('3.4.beta2').should       > f('3.4.beta')
    f('3.4.beta2').hash.should  eql('3.4.beta2'.hash)
  end

end