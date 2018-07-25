class CreateItemTypeAttributes < ActiveRecord::Migration
  def self.up
    create_table :item_type_attributes do |t|
      t.references :item_type
    end

    create_table :item_type_attribute_translations do |t|
      t.references :item_type_attribute
      t.string :locale
      t.string :value
    end
  end

  def self.down
    drop_table :item_type_attributes
    drop_table :item_type_attribute_translations
  end
end
