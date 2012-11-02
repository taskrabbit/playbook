# inherit from this class and implement the #store method
module Playbook
  class Throttler
    
    attr_reader :access_token
    attr_reader :user_id
    attr_reader :unlimited
    attr_reader :limit
    
    def initialize(token, user_id = nil, limit = nil)
      @access_token = token
      @user_id = user_id
      @limit = limit
      @unlimited = @limit.nil?
    end
    
    def record_request!
      store.try(:incr, rate_key)
    end
    
    def needs_rate_limiting?
      !@unlimited
    end
    
    def validate_request!
      return true unless self.needs_rate_limiting?
      raise Playbook::Errors::OverRateLimitError unless self.within_rate_limit?
    end
    
    def within_rate_limit?
      self.rated_request_count <= limit
    end
    
    def rated_request_count
      store.try(:get, rate_key).to_i
    end
    
    def stats
      return "unlimited" if needs_rate_limiting?
      return "#{rated_request_count} of #{@limit}"
    end

    protected

    def store
      nil
    end
    
    def reate_key
      rate = ::Playbook.config.throttler_rate.to_i
      time_key = rate > 0 ? Time.now.to_i / rate : rate
      "api-throttling-#{@access_token}-#{@user_id || 'all'}-#{}"
    end
  end

end