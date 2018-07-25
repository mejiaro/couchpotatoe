class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.string :firstname, :lastname, :email, :phone, :profession, :country
      t.integer :age
      t.text :message

      t.date :start_date, :end_date
      t.string :state
      t.references :account, :rentable_item
      t.timestamps
    end
  end

  def self.down
    drop_table :requests
  end
end
