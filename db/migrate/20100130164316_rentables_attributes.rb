class RentablesAttributes < ActiveRecord::Migration
  def self.up
    create_table :rentables_attributes, :id => false do |t|
      t.references :rentable_item
      t.references :item_type_attribute
    end
  end

  def self.down
  end
end
