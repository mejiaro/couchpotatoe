class AddIndizes < ActiveRecord::Migration
  def self.up
    add_index :users, :debitoren_nr, :unique => true
    add_index :users, :kreditoren_nr, :unique => true
    add_index :contracts, [:rentable_item_id, :end_date], :name => 'last_contract'
  end

  def self.down
    remove_index :users, :column => :debitoren_nr
    remove_index :users, :column => :kreditoren_nr
    remove_index :contracts, :column => [:rentable_item_id, :end_date], :name => 'last_contract'
  end
end
