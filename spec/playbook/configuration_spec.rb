require 'spec_helper'

describe Playbook::Configuration do 

  let(:conf){ ::Playbook.config }

  it 'should be cached at the playbook level' do
    conf.object_id.should eql(::Playbook.config.object_id)
  end

  it 'should not allow the versions to be set directly' do
    conf.should_not respond_to(:versions=)
  end

  it 'should register versions and uniquify them' do
    conf.register_version 3.0
    conf.register_version 2.1
    conf.register_version 3

    conf.versions.map(&:to_s).should eql(%w(2.1 3.0))
  end

  context 'with a realistic version config' do

    let(:conf){
      ::Playbook.config do |c|
        c.register_versions 1.1, 2.0, 2.1, 2.2, '2.2.beta', '2.2.beta2', '3'
      end
    }

    let(:version_strings){ %w(1.1 2.0 2.1 2.2.beta 2.2.beta2 2.2 3.0) }

    it 'should provide an ordered list of the versions' do
      conf.versions.map(&:to_s).should eql(version_strings)
    end

    it 'should provide descending versions' do
      conf.descending_versions.should eql(version_strings.reverse)
    end

    it 'should provide the most recent version properly' do
      conf.descending_versions(2.1).should eql(%w(2.1 2.0 1.1))
      conf.descending_versions(2.4).should eql(%w(2.2 2.2.beta2 2.2.beta 2.1 2.0 1.1))
      conf.descending_versions(1.0).should eql([])
      conf.descending_versions(3.5).should eql(version_strings.reverse)
      conf.descending_versions.should eql(version_strings.reverse)
    end

    it 'should provide the most recent version properly' do
      conf.most_recent_version(2.1).should eql('2.1')
      conf.most_recent_version(2.4).should eql('2.2')
      conf.most_recent_version(1.0).should be_nil
      conf.most_recent_version(3.5).should eql(version_strings.reverse.first)
      conf.most_recent_version.should eql(version_strings.reverse.first)
    end

    it 'should provide the latest version' do
      conf.latest_version.should eql('3.0')
    end

    it 'should retrieve the major and beta versions' do
      conf.major_versions.should eql(%w(2.0 3.0))
      conf.beta_versions.should eql(%w(2.2.beta 2.2.beta2))
    end

    it 'should detrmine if it has a version' do
      conf.has_version?('2.1').should be_true
      conf.has_version?('1.3').should be_false
    end

  end

end