class Playbook::User < Struct.new(:id, :email, :activated, :verified_login)

  INSTANCES = [
    new(1, 'test1@example.com'),
    new(2, 'test2@example.com'),
    new(3, 'test3@example.com')
  ]

  class << self

    def find(id)
      instance = INSTANCES.detect{|i| i.id == id.to_i}
      raise ActiveRecord::RecordNotFound unless instance
      instance
    end

    def find_by_email(email)
      INSTANCES.detect{|i| i.email == email}
    end

  end

  def activated?
    self.activated.nil? || !!self.activated
  end

end