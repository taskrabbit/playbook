require 'digest/sha1'

module Playbook
  class Keygen
    class << self

      def generate_api_key(length = 40, user = nil)
        Digest::SHA1.hexdigest("#{user.try(:hash)}#{Time.now}#{rand(9999)}")[0...length]
      end

    end
  end
end