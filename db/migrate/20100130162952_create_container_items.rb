class CreateContainerItems < ActiveRecord::Migration
  def self.up

    create_table :container_items do |t|
      t.string  :address, :zip, :city, :country
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.references :account
      t.timestamps
    end

    create_table :container_item_translations do |t|
      t.string :locale
      t.references :container_item
      t.text :description
      t.string :name
    end

  end


  def self.down
    drop_table :container_items
  end


end
