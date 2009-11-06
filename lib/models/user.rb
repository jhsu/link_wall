class User < Sequel::Model

  def self.authenticate(username, password)
    return new
  end
end
