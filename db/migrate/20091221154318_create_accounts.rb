class CreateAccounts < ActiveRecord::Migration

  def self.up
    create_table :accounts do |t|
      t.string :name, :address, :zip, :city, :country, :phone, :fax, :email
      t.string :layout_public, :layout_lodger, :suddomain, :domain, :general_keywords
      t.string :tax_number, :bank_name, :bank_account, :bank_code, :iban, :bic
      t.string :google_maps_api_key
      t.timestamps
    end

    create_table :account_translations do |t|
      t.string :locale
      t.references :account
      t.text :imprint, :payment_instructions
    end
  end

  def self.down
    drop_table :accounts
  end

end
