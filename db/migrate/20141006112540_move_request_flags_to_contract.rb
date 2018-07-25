class MoveRequestFlagsToContract < ActiveRecord::Migration
  def change
    Request.all.each do |request|
      if request.contract.present? && request.contract_verified
        c = request.contract
        c.contract_verified = true
        c.save(validate: false)
      end
      if request.contract.present? && request.passport_verified
        c = request.contract
        c.passport_verified = true
        c.save(validate: false)
      end
      if request.contract.present? && request.deposit_paid
        c = request.contract
        c.deposit_paid = true
        c.save(validate: false)
      end
    end
  end
end
