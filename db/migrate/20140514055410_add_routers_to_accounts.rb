class AddRoutersToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :routers, :text
  end

  def self.down
    remove_column :accounts, :routers
  end
end
