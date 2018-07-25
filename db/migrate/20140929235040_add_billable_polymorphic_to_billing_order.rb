class AddBillablePolymorphicToBillingOrder < ActiveRecord::Migration
  def change
    add_column :billing_orders, :billable_type, :string
    add_column :billing_orders, :billable_id, :integer
  end
end
