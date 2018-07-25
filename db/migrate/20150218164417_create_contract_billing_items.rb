class CreateContractBillingItems < ActiveRecord::Migration
  def change
    create_table :contract_billing_items do |t|
      t.references :contract, index: true
      t.references :billing_item, index: true

      t.timestamps
    end
  end
end
