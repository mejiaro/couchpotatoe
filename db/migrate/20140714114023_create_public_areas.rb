class CreatePublicAreas < ActiveRecord::Migration
  def up
    create_table :public_areas do |t|
      t.string :name
      t.references :account
      t.references :container_item
    end
  end

  def down
    drop_table :public_areas
  end
end
