class AddFieldsToReceivables < ActiveRecord::Migration

  def self.up
    add_column :receivables, :amount, :float
    add_column :receivables, :direct_debit, :boolean
    add_column :receivables, :exported, :boolean
    add_column :receivables, :billing_cycle_id, :integer
  end

  def self.down
    remove_column :receivables, :amount
    remove_column :receivables, :direct_debit
    remove_column :receivables, :exported
    remove_column :receivables, :billing_cycle_id
  end
  
end
