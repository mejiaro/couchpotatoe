class CreateBillingItems < ActiveRecord::Migration
  def change
    create_table :billing_items do |t|
      t.string :name
      t.string :number
      t.text :description

      t.string :billing_account
      t.integer :price_in_cents
      t.integer :flags

      t.references :account

      t.timestamps
    end
  end
end
