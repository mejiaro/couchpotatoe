class AddContractIdToPayments < ActiveRecord::Migration
  def up
    add_reference :payments, :contract, index: true

    Payment.all.each do |payment|
      if payment.receivable.present?
        payment.contract_id = payment.receivable.contract_id
        payment.save!
      end
    end
  end

  def down
    remove_reference :payments, :contract
  end
end
