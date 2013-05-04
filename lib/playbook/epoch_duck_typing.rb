# epoch times are 10 digit numbers
# if they are comprised of the correct ranges they can be parsed into a date by Date.parse.
# Rails happens to check if the string acts_like a time before invoking this
# by overriding this method we enable epoch times to be passed around as strings
# without Date.parse ever being invoked.
# the format is as follows:
# * 4 digits representing a year :: [\d]{4}
# * 2 digits representing a month (01 - 12) :: (0[1-9]|1[0-2])
# * 2 digits representing a day (01 - 31) :: (0[1-9]|[1-2][0-9]|3[0-1])
# * 2 digits which are ignored by Date.parse :: [\d]{2}

module Playbook
  module EpochDuckTyping

    def acts_like?(duck)
      if [:time, :date, :datetime, :timestamp].include?(duck)
        epoch_timestamp? || super
      else
        super
      end
    end

    def epoch_timestamp?
      !!(self =~ /^[\d]{4}(0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])[\d]{2}$/)
    end

  end
end