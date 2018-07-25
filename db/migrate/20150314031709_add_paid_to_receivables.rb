class AddPaidToReceivables < ActiveRecord::Migration
  def change
    add_column :receivables, :is_paid, :boolean
  end
end
