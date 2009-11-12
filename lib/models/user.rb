class User < ActiveRecord::Base
  has_many :links

  def self.authenticate(username, password)
    first(:conditions => ["username = ?", username])
  end
end
