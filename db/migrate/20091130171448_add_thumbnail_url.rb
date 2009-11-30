class AddThumbnailUrl < ActiveRecord::Migration
  def self.up
    add_column :links, :thumbnail_url, :string
  end

  def self.down
    remove_column :links, :thumbnail_url
  end
end
