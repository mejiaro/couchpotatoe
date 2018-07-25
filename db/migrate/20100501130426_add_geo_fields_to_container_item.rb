class AddGeoFieldsToContainerItem < ActiveRecord::Migration
  def self.up
    add_column :container_items, :lat, :decimal, :precision => 15, :scale => 10
    add_column :container_items, :lng, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :container_items, :lat
    remove_column :container_items, :lng
  end
  
end
