class AddBankAccountHolderToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :bank_account_holder, :string
  end

  def self.down
    remove_column :users, :bank_account_holder
  end
  
end
