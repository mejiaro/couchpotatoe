class AddTemplatesToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :bill_template, :string
    add_column :accounts, :contract_template, :string
  end
end
