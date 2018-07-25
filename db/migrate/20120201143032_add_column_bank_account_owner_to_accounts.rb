class AddColumnBankAccountOwnerToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :bank_account_owner, :string
  end

  def self.down
    remove_column :accounts, :bank_account_owner
  end
end
