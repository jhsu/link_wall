class IndexLinkToken < ActiveRecord::Migration
  def self.up
    add_index :links, :token
  end

  def self.down
    remove_index :links, :token
  end
end
