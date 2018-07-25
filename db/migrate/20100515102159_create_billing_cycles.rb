class CreateBillingCycles < ActiveRecord::Migration
  def self.up
    create_table :billing_cycles do |t|
      t.string :note
      t.integer :month, :year
      
      t.references :account
      t.timestamps
    end
  end

  def self.down
    drop_table :billing_cycles
  end
end
