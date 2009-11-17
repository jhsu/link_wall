class CreateUsers < ActiveRecord::Migration
  def self.up
  create_table :users do |u|
      u.string :username, :null => false
      u.string :encrypted_password
      u.string :password_salt

      u.timestamp :created_at
      u.timestamp :updated_at
    end
  end

  def self.down
    drop_table :users
  end
end
