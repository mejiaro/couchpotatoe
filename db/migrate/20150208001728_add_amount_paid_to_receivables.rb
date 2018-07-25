class AddAmountPaidToReceivables < ActiveRecord::Migration
  def change
    add_column :receivables, :amount_paid, :integer
  end
end
