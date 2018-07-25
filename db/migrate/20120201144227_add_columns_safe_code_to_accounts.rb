class AddColumnsSafeCodeToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :safe_code, :string
  end

  def self.down
    remove_column :accounts, :safe_code
  end
end
