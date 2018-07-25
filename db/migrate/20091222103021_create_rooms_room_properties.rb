class CreateRoomsRoomProperties < ActiveRecord::Migration
  def self.up
    create_table :room_attributes_rooms, :id => false do |t|

      t.integer :room_id, :room_attribute_id

    end
  end

  def self.down
    drop_table :room_attributes_rooms
  end
  
end
