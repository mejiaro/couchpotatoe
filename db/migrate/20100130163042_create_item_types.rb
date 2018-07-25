class CreateItemTypes < ActiveRecord::Migration
  def self.up
    create_table :item_types do |t|
      t.references :typeable
      t.timestamps
    end

    create_table :item_type_translations do |t|
      t.string :locale
      t.references :item_type
      t.string :name
    end
  end

  def self.down
    drop_table :item_types
    drop_table :item_type_translations
  end
end
