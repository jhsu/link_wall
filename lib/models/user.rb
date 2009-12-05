class User < ActiveRecord::Base
  has_many :groups
  has_many :links, :through => :groups

  def self.authenticate(username, password)
    user = first(:conditions => ["username = ?", username])
    if !user.nil?
      User.encrypt(password, user.password_salt) == user.encrypted_password ? user : nil
    else
      return nil
    end
  end

  def password=(pass)
    self.password_salt = "#{Time.now.to_i}#{username}"
    self.encrypted_password = self.class.encrypt(pass, self.password_salt)
  end

  def self.encrypt(pass,salt)
    Digest::SHA1.hexdigest(salt + pass)
  end
end
