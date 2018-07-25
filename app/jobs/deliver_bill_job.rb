class DeliverBillJob < ActiveJob::Base
  queue_as :default

  def perform(contract, current)
    file = CustomDocumentGenerator.contract_bill(contract, current: current)
    ContractMailer.deliver_bill(contract, file, current).deliver_now
  end
end
