class AddHashToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :hash, :string
  end

  def self.down
    remove_column :requests, :hash
  end
end
