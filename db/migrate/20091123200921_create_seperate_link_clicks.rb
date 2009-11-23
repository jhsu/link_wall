class CreateSeperateLinkClicks < ActiveRecord::Migration
  def self.up
    create_table :clicks do |c|
      c.integer   :link_id
      c.string    :ip_address
      c.timestamp :created_at
    end
    remove_column :links, :clicks
  end

  def self.down
    drop_table :clicks
    add_column :links, :clicks, :integer
  end
end
