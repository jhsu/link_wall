class User < ActiveRecord::Base
  has_many :groups
  has_many :links, :through => :groups

  def self.authenticate(username, password)
    first(:conditions => ["username = ?", username])
  end
end
