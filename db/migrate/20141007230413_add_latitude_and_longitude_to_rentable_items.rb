class AddLatitudeAndLongitudeToRentableItems < ActiveRecord::Migration
  def change
    add_column :rentable_items, :latitude, :float
    add_column :rentable_items, :longitude, :float
  end
end
