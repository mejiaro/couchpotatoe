class AddBillableTypeAndIdToReceivables < ActiveRecord::Migration
  def change
    add_column :receivables, :billable_type, :string
    add_reference :receivables, :billable, index: true
  end
end
