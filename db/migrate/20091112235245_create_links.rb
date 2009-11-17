class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.string    :url, :null => false
      t.integer   :user_id, :null => false
      t.string    :image_url

      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end

  def self.down
    drop_table :links
  end
end
