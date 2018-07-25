class AddDepositsBankAccountToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :deposits_bank_name, :string
    add_column :accounts, :deposits_iban, :string
    add_column :accounts, :deposits_bic, :string
    add_column :accounts, :deposits_bank_account_owner, :string
  end
end
