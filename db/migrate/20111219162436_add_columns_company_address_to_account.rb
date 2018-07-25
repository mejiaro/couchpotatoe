class AddColumnsCompanyAddressToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :company_address, :string
    add_column :accounts, :company_zip, :string
    add_column :accounts, :company_city, :string
    add_column :accounts, :company_country, :string
    add_column :accounts, :company, :string
  end

  def self.down
    remove_column :accounts, :company_address
    remove_column :accounts, :company_zip
    remove_column :accounts, :company_city
    remove_column :accounts, :company_country
    remove_column :accounts, :company
  end
end
