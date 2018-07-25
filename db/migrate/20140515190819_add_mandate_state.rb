class AddMandateState < ActiveRecord::Migration
  def self.up
    add_column :users, :mandate_changed, :datetime, :default => nil
    add_column :contracts, :next_mandate_state, :string, :default => 'FRST'
    add_column :receivables, :mandate_state, :string, :default => nil
  end

  def self.down
    remove_column :receivables, :mandate_state
    remove_column :contracts, :next_mandate_state
    remove_column :users, :mandate_changed
  end
end
