class AddEarliestAvailableToRentableItems < ActiveRecord::Migration
  def change
    add_column :rentable_items, :earliest_available, :date
  end
end
