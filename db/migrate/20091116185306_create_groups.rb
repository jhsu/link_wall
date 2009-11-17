class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :token, :null => false
    end

    change_table :links do |t|
    end
  end

  def self.down
    drop_table :groups
    change_table :links do |t|
    end
  end
end
