class AddAdNameToRentableItems < ActiveRecord::Migration
  def change
    add_column :rentable_items, :ad_name, :string
  end
end
