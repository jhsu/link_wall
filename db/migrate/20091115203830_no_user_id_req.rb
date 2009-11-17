class NoUserIdReq < ActiveRecord::Migration
  def self.up
    remove_column :links, :user_id
    add_column :links, :user_id, :integer
  end

  def self.down
    change_column :links, :user_id, :integer, :null => false
  end
end
