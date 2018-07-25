class AddInternetToContract < ActiveRecord::Migration
  def self.up
    add_column :contracts, :internet, :boolean
  end

  def self.down
    remove_column :contracts, :internet
  end
end
