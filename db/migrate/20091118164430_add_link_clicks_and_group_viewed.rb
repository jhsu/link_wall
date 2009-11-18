class AddLinkClicksAndGroupViewed < ActiveRecord::Migration
  def self.up
    add_column :groups, :created_at, :datetime
    add_column :groups, :updated_at, :datetime

    add_column :groups, :views,  :integer, :default => 0
    add_column :links,  :clicks, :integer, :default => 0

    add_index :users, :username
  end

  def self.down
    remove_column :groups, :created_at
    remove_column :groups, :updated_at

    remove_column :groups, :views
    remove_column :links,  :clicks

    remove_index :users, :username
  end
end
