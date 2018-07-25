class CreateRoomStates < ActiveRecord::Migration
  def self.up
    create_table :room_states do |t|
      t.string :reason, :null => false

      t.integer :bed_count, :null => false
      t.boolean :bed_ok, :default => true, :null => false
      t.string  :bed_comment, :null => false
      t.integer :armchair_count, :null => false
      t.boolean :armchair_ok, :default => true, :null => false
      t.string  :armchair_comment, :null => false
      t.integer :mattress_count, :null => false
      t.boolean :mattress_ok, :default => true, :null => false
      t.string  :mattress_comment, :null => false
      t.integer :bin_count, :null => false
      t.boolean :bin_ok, :default => true, :null => false
      t.string  :bin_comment, :null => false
      t.integer :closet_count, :null => false
      t.boolean :closet_ok, :default => true, :null => false
      t.string  :closet_comment, :null => false
      t.integer :dresser_count, :null => false
      t.boolean :dresser_ok, :default => true, :null => false
      t.string  :dresser_comment, :null => false
      t.integer :floor_lamp_count, :null => false
      t.boolean :floor_lamp_ok, :default => true, :null => false
      t.string  :floor_lamp_comment, :null => false
      t.integer :slatted_frame_count, :null => false
      t.boolean :slatted_frame_ok, :default => true, :null => false
      t.string  :slatted_frame_comment, :null => false
      t.integer :desk_count, :null => false
      t.boolean :desk_ok, :default => true, :null => false
      t.string  :desk_comment, :null => false
      t.integer :chair_count, :null => false
      t.boolean :chair_ok, :default => true, :null => false
      t.string  :chair_comment, :null => false
      t.integer :curtain_count, :null => false
      t.boolean :curtain_ok, :default => true, :null => false
      t.string  :curtain_comment, :null => false
      t.integer :sofa_count, :null => false
      t.boolean :sofa_ok, :default => true, :null => false
      t.string  :sofa_comment, :null => false
      t.integer :box_count, :null => false
      t.boolean :box_ok, :default => true, :null => false
      t.string  :box_comment, :null => false

      t.integer :key_count, :null => false
      t.integer :door_chip_count, :null => false

      t.string :comment

      t.references :account, :rentable_item, :user, :employee

      t.timestamps
    end
  end

  def self.down
    drop_table :room_states
  end
end
