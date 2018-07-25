class ChangeDescriptionToTextRentableItems < ActiveRecord::Migration
  def up
    change_column :rentable_items, :description, :text
  end
  def down
    # This might cause trouble if you have strings longer
    # than 255 characters.
    change_column :rentable_items, :description, :string
  end
end
