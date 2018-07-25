class CreateRentableItemPositions < ActiveRecord::Migration
  def self.up
    create_table :rentable_item_positions do |t|
      t.string :title
      t.integer :x, :y, :width, :height
      t.references :container_item, :floor_plan, :account
      t.timestamps
    end
  end

  def self.down
    drop_table :rentable_item_positions
  end
end
