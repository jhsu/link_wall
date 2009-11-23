class CreateUsers < ActiveRecord::Migration
  def self.up
  create_table :users do |u|
      u.string :username, :null => false
      u.string :encrypted_password
      u.string :password_salt

      u.timestamp :created_at
      u.timestamp :updated_at
    end

    remove_column :links, :clicks
  end

  def self.down
    drop_table :clicks

    add_column :links, :clicks, :integer
  end
end
