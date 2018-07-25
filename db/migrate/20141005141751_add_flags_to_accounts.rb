class AddFlagsToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :flags, :integer
  end
end
