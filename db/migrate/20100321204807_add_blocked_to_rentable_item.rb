class AddBlockedToRentableItem < ActiveRecord::Migration
  def self.up
    add_column :rentable_items, :blocked, :boolean, :default => false
  end

  def self.down
    remove_column :rentable_items, :blocked
  end
end
