class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :token, :null => false
      t.integer :user_id
    end
    add_index :groups, :token

    add_column :links, :group_id, :integer
    remove_column :links, :token
  end

  def self.down
    drop_table :groups

    remove_column :links, :group_id
    add_column :links, :token, :null => false
  end
end
