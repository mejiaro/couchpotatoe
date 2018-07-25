class AddMailerConfigurationToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :mail_server, :string
    add_column :accounts, :mail_port, :integer
    add_column :accounts, :mail_hostname, :string
    add_column :accounts, :mail_user, :string
    add_column :accounts, :mail_pass, :string
  end

  def self.down
    remove_column :accounts, :mail_server
    remove_column :accounts, :mail_port
    remove_column :accounts, :mail_hostname
    remove_column :accounts, :mail_user
    remove_column :accounts, :mail_pass
  end
end
