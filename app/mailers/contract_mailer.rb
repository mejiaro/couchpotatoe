class ContractMailer < ApplicationMailer
  def deliver_bill(contract, bill_file, current)
    @contract = contract
    @current = current

    filename = "#{ current ? 'Zwischenabrechnung' : 'Abrechnung' } #{contract.id} - #{ contract.rentable_item.number } - #{ contract.user.fullname }.pdf"
    attachments[filename] = File.read(bill_file)
    mail({
      to: contract.user.email,
      subject: "#{@current ? 'Zwischenabrechnung' : 'Abrechnung'} Mietverhältniss"
    })
  end

  def after_create_user(contract)
    filename = "Vertrag-#{contract.rentable_item.number}-#{contract.user.fullname}.pdf"
    attachments[filename] = File.read(contract.blank_contract.document.path)
    @contract = contract
    mail(to: @contract.user.email, subject: "Vertrag wurde erstellt | #{ @contract.account.public_name }")
  end

  def after_create_account(contract)
    filename = "Vertrag-#{contract.rentable_item.number}-#{contract.user.fullname}.pdf"
    attachments[filename] = File.read(contract.blank_contract.document.path)
    @contract = contract
    mail(to: @contract.account.employees.compact.map(&:email), subject: "Vertragserstellung für #{ @contract.rentable_item.number }")
  end

  def user_signed_user(contract)
    filename = "Vertrag-#{contract.rentable_item.number}-#{contract.user.fullname} (Du hast unterschrieben).pdf"
    attachments[filename] = File.read(contract.signed_contract.document.path)
    @contract = contract
    mail(to: @contract.user.email, subject: "Du hast unterschrieben | #{ @contract.account.public_name }")
  end

  def user_signed_account(contract)
    filename = "Vertrag-#{contract.rentable_item.number}-#{contract.user.fullname} (Mieter hat unterschrieben).pdf"
    attachments[filename] = File.read(contract.signed_contract.document.path)
    @contract = contract
    mail(to: @contract.account.employees.compact.map(&:email), subject: "Unterschrift von #{@contract.user.fullname} für #{ @contract.rentable_item.number } liegt vor")
  end

  def landlord_signed_tenant(contract)
    filename = "Vertrag-#{contract.rentable_item.number}-#{contract.user.fullname} (Unterschrieben).pdf"
    attachments[filename] = File.read(contract.signed_contract(true).document.path)
    @contract = contract
    mail(to: @contract.user.email, subject: "Vermieter hat unterschrieben | #{ @contract.account.public_name }")
  end

  def landlord_signed_landlord(contract)
    filename = "Vertrag-#{contract.rentable_item.number}-#{contract.user.fullname} (Unterschrieben).pdf"
    attachments[filename] = File.read(contract.signed_contract(true).document.path)
    @contract = contract
    mail(to: @contract.account.employees.compact.map(&:email), subject: "Sie haben unterschrieben | Inserat #{ @contract.rentable_item.number }")
  end
end
