class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.string :number, :origin, :state
      t.integer :price_in_cents, :deposit_in_cents, :extras_in_cents
      t.date :start_date
      t.date :end_date
      t.references :user, :rentable_item, :account
      t.timestamps

    end
  end

  def self.down
    drop_table :contracts
  end
end
