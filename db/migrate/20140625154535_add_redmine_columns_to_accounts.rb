class AddRedmineColumnsToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :redmine_url, :string
    add_column :accounts, :redmine_api_token, :string
    add_column :accounts, :redmine_categories, :text
  end

  def self.down
    remove_column :accounts, :redmine_categories
    remove_column :accounts, :redmine_api_token
    remove_column :accounts, :redmine_url
  end
end
