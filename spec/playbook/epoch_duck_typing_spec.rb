require 'spec_helper'

describe ::Playbook::EpochDuckTyping do

  class Substring < String
    include ::Playbook::EpochDuckTyping
  end

  [
    ['test', false],
    ['', false],
    [' ', false],
    ['0', false],
    ['1367130420', false],
    ['1367000420', false],
    ['1367200420', false],
    ['1367120420', true],
    ['1367020420', true],
    ['1367110420', true],
    ['1367120020', false],
    ['1367023220', false],
    ['1367114020', false],
    ['1367120120', true],
    ['1367021220', true],
    ['1367111020', true],
    ['1367120400', true],
    ['1367020499', true],
    ['1367110409', true],
    ['1367120490', true]
  ].each do |input, expectation|
    it "#{expectation ? 'expects' : 'does not expect'} '#{input}' to be evaluated as an epoch timestamp" do
      s = Substring.new(input)
      if expectation
        s.should be_an_epoch_timestamp
      else
        s.should_not be_an_epoch_timestamp
      end
    end
  end

end