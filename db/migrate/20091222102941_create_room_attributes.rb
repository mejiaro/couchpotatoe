class CreateRoomAttributes < ActiveRecord::Migration

  def self.up
    create_table :room_attributes do |t|
      t.timestamps
    end
  end

    create_table :room_attribute_translations do |t|
      t.references :room_attribute
      t.string :locale
      t.string :value
    end

  def self.down
    drop_table :room_attributes
  end
end
