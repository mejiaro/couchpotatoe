class AddFeaturedToRentableItems < ActiveRecord::Migration
  def change
    add_column :rentable_items, :featured, :boolean
  end
end
