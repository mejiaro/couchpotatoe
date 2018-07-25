class AddColumnFlagsToContracts < ActiveRecord::Migration
  def self.up
    add_column :contracts, :flags, :integer
  end

  def self.down
    remove_column :contracts, :flags
  end
end
