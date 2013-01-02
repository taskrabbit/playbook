class Playbook::ClientApplication < Struct.new(:id, :key, :secret, :internal, :interactive)

  INSTANCES = [
    new(1, 'WhVYrBvwEqX7zZ14TgFHL831BBv7UKUrZXiZIYBz', '6VkbXQ3o8Qz4jjNk3FOrh7afmgyYKJiibXF6R4A2', true, false),
    new(2, 'bIJgZ7j8Ez9XKs4DfFaQiXdawP68bNSVBcsdJhd2', 'eOpADZXvkYJWZGwjVjmWTw40vxF2HRYbj4MJDKA0', false, false),
    new(3, 'RjiNUcRn0zudmPjGGP4T1CBfuslNzbySmxiW1e4A', 'tp6bPtlmxgSbbZxuyty7Lku0bO1twodKtng0gRNg', true, true)
  ]

  class << self

    def find(id)
      instance = INSTANCES.detect{|i| i.id == id.to_i}
      raise ActiveRecord::RecordNotFound unless instance
      instance
    end

    def find_by_secret(secret)
      INSTANCES.detect{|i| i.secret == secret}
    end

  end

  def update_attribute(key, val)
    self.send("#{key}=", val)
  end

  def internal?
    !!self.internal
  end

  def interactive?
    !!self.interactive
  end
end