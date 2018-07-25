class AddContractToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :contract_id, :integer
  end
end
