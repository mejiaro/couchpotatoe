class GenerateContractJob < ActiveJob::Base
  queue_as :default

  def perform(contract)
    file = if contract.account.contract_template.present?
                            CustomDocumentGenerator.blank_contract(contract)
                          else
                            DefaultDocumentGenerator.generate_contract(contract)
                          end

    a = contract.attachments.build(document: File.open(file), document_type: 'blank_contract')
    a.save!
    
    contract.send_blank_contract
  end
end
