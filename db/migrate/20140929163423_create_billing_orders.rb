class CreateBillingOrders < ActiveRecord::Migration
  def change
    create_table :billing_orders do |t|
      t.integer :ebics_order_id
      t.integer :flags
      t.references :account

      t.timestamps
    end

    add_column :receivables, :billing_order_id, :integer
  end
end
