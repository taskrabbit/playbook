class Playbook::Oauth2Token < Struct.new(:id, :token, :secret, :user_id, :client_application_id)

  INSTANCES = [[1,1], [1,2], [1,3], [2,1], [2,2], [2,3], [3,1], [3,2], [3,3]].map do |user_id, client_id|
    new(1, "abcdefghijklmnopqrstuvwxyz#{user_id}#{client_id}", "secretjklmnopqrstuvwxyz#{user_id}#{client_id}", user_id, client_id)
  end

  def initialize(*args)
    if args.first.is_a?(Hash)
      super()
      args.first.each do |k,v|
        self.send("#{k}=", v)
      end
    else
      super
    end
  end

  class << self

    def find(id)
      instance = INSTANCES.detect{|i| i.id == id.to_i}
      raise ActiveRecord::RecordNotFound unless instance
      instance
    end

    def find_by_token(token)
      INSTANCES.detect{|i| i.token == token}
    end

  end

  def user
    self.user_id ? Playbook::User.find(self.user_id) : nil
  end

  def user=(u)
    self.user_id = u.try(:id)
  end

  def client_application
    self.client_application_id ? Playbook::ClientApplication.find(self.client_application_id) : nil
  end

  def client_application=(ca)
    self.client_application_id = ca.try(:id)
  end

  def authorized?
    true
  end

end