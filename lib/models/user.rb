class User < ActiveRecord::Base
  has_many :links

  def self.authenticate(username, password)
    return new
  end
end
