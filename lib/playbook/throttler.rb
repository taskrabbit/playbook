# inherit from this class and implement the #store method
module Playbook
  class Throttler
    
    attr_reader :api_key
    attr_reader :user_id
    attr_reader :unlimited
    attr_reader :limit
    
    def initialize(key, user_id = nil, limit = nil)
      @api_key = key
      @user = user
      @limit = limit
      @unlimited = @limit.nil?
    end
    
    def record_request!
      store.try(:incr, hour_key)
    end
    
    def needs_rate_limiting?
      !self.unlimited
    end
    
    def validate_request!
      return true unless self.needs_rate_limiting?
      raise Playbook::Errors::OverRateLimitError unless self.within_rate_limit?
    end
    
    def within_rate_limit?
      self.hourly_request_count <= limit
    end
    
    def hourly_request_count
      store.try(:get, hour_key).to_i
    end
    
    def stats
      return "unlimited" if needs_rate_limiting?
      return "#{hourly_request_count} of #{limit}"
    end

    protected

    def store
      nil
    end
    
    def hour_key
      "api-throttling-#{api_key}-#{user_id || 'all'}-#{Time.now.strftime("%Y-%m-%d-%H")}"
    end
  end

end