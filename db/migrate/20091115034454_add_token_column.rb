class AddTokenColumn < ActiveRecord::Migration
  def self.up
    add_column :links, :token, :string
  end

  def self.down
    remove_column :links, :token
  end
end
