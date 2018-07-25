class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :type
      t.datetime :from
      t.datetime :till
      t.text :notes
      t.string :title
      t.integer :schedulable_id
      t.string :schedulable_type
      t.integer :owner_id
      t.string :owner_type
      t.timestamps
    end
  end
end
