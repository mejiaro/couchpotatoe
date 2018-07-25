class AddColumnsWebsiteToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :website, :string
  end

  def self.down
    remove_column :accounts, :website
  end
end
