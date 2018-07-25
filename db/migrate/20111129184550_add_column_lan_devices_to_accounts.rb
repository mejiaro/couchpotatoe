class AddColumnLanDevicesToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :mac_list, :text
  end

  def self.down
    remove_column :accounts, :mac_list
  end
end
