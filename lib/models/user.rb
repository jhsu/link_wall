class User < ActiveRecord::Base
  has_many :groups
  has_many :links, :through => :groups

  before_create :generate_api_key!

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

  def generate_api_key!
    self.api_key =  Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..34]
  end
end
