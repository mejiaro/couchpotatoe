class AddCreditorId < ActiveRecord::Migration
  def self.up
    add_column :accounts, :creditor_id, :string
  end

  def self.down
    remove_column :accounts, :creditor_id
  end
end
