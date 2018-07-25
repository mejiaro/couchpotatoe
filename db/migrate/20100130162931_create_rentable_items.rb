class CreateRentableItems < ActiveRecord::Migration
  def self.up
    create_table :rentable_items do |t|
      t.string :number
      t.integer :price_in_cents, :deposit_in_cents
      t.float :size

      t.references :account, :container_item
      t.timestamps
    end

    create_table :rentable_item_translations do |t|
      t.string :locale
      t.references :rentable_item
      t.text :description
    end
  end

  def self.down
    drop_table :rentable_items
    drop_table :rentable_item_translations
  end
end
