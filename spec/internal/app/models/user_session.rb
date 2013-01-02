begin
  ::UserSession.name
rescue
  class UserSession < Struct.new(:record_id)

    class << self
      def find
        new(nil)
      end
    end

  end
end