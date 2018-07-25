class AddColumnDraftToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :draft, :boolean
  end

  def self.down
    remove_column :accounts, :draft
  end
end
