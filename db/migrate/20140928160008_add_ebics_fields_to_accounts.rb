class AddEbicsFieldsToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :ebics_host_id, :string
    add_column :accounts, :ebics_partner_id, :string
    add_column :accounts, :ebics_user_id, :string
    add_column :accounts, :ebics_url, :string
  end
end
