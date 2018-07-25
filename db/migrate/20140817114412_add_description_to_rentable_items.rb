class AddDescriptionToRentableItems < ActiveRecord::Migration
  def up
    add_column :rentable_items, :description, :string
  end

  def  down
    remove_column :rentable_items, :description
  end
end
