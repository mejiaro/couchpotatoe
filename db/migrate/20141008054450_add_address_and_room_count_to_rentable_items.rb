class AddAddressAndRoomCountToRentableItems < ActiveRecord::Migration
  def change
    add_column :rentable_items, :address, :string
    add_column :rentable_items, :city, :string
    add_column :rentable_items, :zip, :string
    add_column :rentable_items, :country, :string
    add_column :rentable_items, :room_count, :float
  end
end
