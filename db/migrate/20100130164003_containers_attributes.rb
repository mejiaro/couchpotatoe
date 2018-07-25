class ContainersAttributes < ActiveRecord::Migration
  def self.up
    create_table :containers_attributes, :id => false do |t|
      t.references :container_item
      t.references :item_type_attribute
    end
  end

  def self.down
    drop_table :containers_attributes
  end
end
