class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :amount_in_cents
      t.string :name
      t.references :receivable, index: true
      t.datetime :paid_on

      t.timestamps
    end
  end
end
