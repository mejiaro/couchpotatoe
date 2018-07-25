class AddColumnsTokenToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :token, :string
  end

  def self.down
    remove_column :accounts, :token
  end
end
