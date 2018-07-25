require 'ostruct'

module CustomDocumentGenerator
  include ActionView::Helpers::NumberHelper
  extend self

  def contract_bill(contract, options)

    tempfile = Tempfile.new(['contract_bill', '.odt'])

    rendered_odt = ODFReport::Report.new(contract.account.bill_template) do |r|

      r.add_field "DATUM", Time.now.strftime('%d.%m.%Y')
      r.add_field "VERMIETER_NAME", contract.account.company
      r.add_field "VERMIETER_STRASSE", contract.account.company_address
      r.add_field "VERMIETER_STADT", contract.account.company_city
      r.add_field "VERMIETER_PLZ", contract.account.company_zip

      r.add_field "VERMIETER_KONTOINHABER", contract.account.bank_account_owner
      r.add_field "VERMIETER_IBAN", contract.account.iban
      r.add_field "VERMIETER_BIC", contract.account.bic
      r.add_field "VERMIETER_BANK", contract.account.bank_name

      r.add_field "MIETER_KONTOINHABER", contract.user .bank_account_holder
      r.add_field "MIETER_IBAN", contract.user.iban
      r.add_field "MIETER_BIC", contract.user.bic
      r.add_field "MIETER_BANK", contract.user.bank_name

      r.add_field "MIETER_NAME", contract.user.fullname
      r.add_field "MIETER_VORNAME", contract.user.firstname
      r.add_field "MIETER_NACHNAME", contract.user.lastname
      r.add_field "MIETER_ANREDE", contract.user.anrede
      r.add_field "MIETER_STRASSE", contract.user.address
      r.add_field "MIETER_STADT", contract.user.city
      r.add_field "MIETER_PLZ", contract.user.zip

      r.add_field "VERTRAGSNUMMER", contract.id
      r.add_field "KUNDENNUMMER", contract.user.id
      r.add_field "SWID", contract.rentable_item.id

      r.add_field "OBJEKT_NAME", contract.rentable_item.number
      r.add_field "OBJEKT_ADRESSE", contract.rentable_item.full_address

      items = if options[:current]
                contract.receivables.current.to_a + contract.payments.current.to_a
              else
                contract.receivables.to_a + contract.payments.to_a
              end

      items.sort_by!(&:credit).sort_by!(&:debit).sort_by!(&:date)

      if contract.deposit_paid?
        items.unshift OpenStruct.new(payment_reference: 'Kaution', date: contract.start_date, credit: contract.deposit, debit: 0)
      end

      r.add_table("FORDERUNGEN", items, :header=>true) do |t|
        t.add_column("VERWENDUNGSZWECK") { |r| r.payment_reference }
        t.add_column("FAELLIG") { |r| r.date.strftime('%d.%m.%Y') }
        t.add_column("BETRAG_FORDERUNG") { |r| r.debit != 0 ? number_to_currency(r.debit) : nil }
        t.add_column("BETRAG_ZAHLUNG") { |r| r.credit != 0 ? number_to_currency(r.credit) : nil }
      end

      r.add_field "SALDO", number_to_currency(contract.balance(options))
    end

    rendered_odt.generate(tempfile)

    return odt_to_pdf(tempfile.path)
  end

  def blank_contract(contract)
    tempfile = Tempfile.new(['contract', '.odt'])

    rendered_odt = ODFReport::Report.new(contract.account.contract_template) do |r|

      r.add_field "DATUM", Time.now.strftime('%d.%m.%Y')
      r.add_field "VERMIETER_NAME", contract.account.company
      r.add_field "VERMIETER_STRASSE", contract.account.company_address
      r.add_field "VERMIETER_STADT", contract.account.company_city
      r.add_field "VERMIETER_PLZ", contract.account.company_zip

      r.add_field "VERMIETER_KONTOINHABER", contract.account.bank_account_owner
      r.add_field "VERMIETER_IBAN", contract.account.iban
      r.add_field "VERMIETER_BIC", contract.account.bic
      r.add_field "VERMIETER_BANK", contract.account.bank_name

      r.add_field "VERMIETER_KONTOINHABER_KAUTION", contract.account.deposits_bank_account_owner
      r.add_field "VERMIETER_IBAN_KAUTION", contract.account.deposits_iban
      r.add_field "VERMIETER_BIC_KAUTION", contract.account.deposits_bic
      r.add_field "VERMIETER_BANK_KAUTION", contract.account.deposits_bank_name

      r.add_field "MIETER_KONTOINHABER", contract.user .bank_account_holder
      r.add_field "MIETER_IBAN", contract.user.iban
      r.add_field "MIETER_BIC", contract.user.bic
      r.add_field "MIETER_BANK", contract.user.bank_name

      r.add_field "MIETER_NAME", contract.user.fullname
      r.add_field "MIETER_VORNAME", contract.user.firstname
      r.add_field "MIETER_NACHNAME", contract.user.lastname
      r.add_field "MIETER_ANREDE", contract.user.anrede
      r.add_field "MIETER_STRASSE", contract.user.address
      r.add_field "MIETER_STADT", contract.user.city
      r.add_field "MIETER_PLZ", contract.user.zip
      r.add_field "MIETER_LAND", contract.user.country

      r.add_field "VERTRAGSNUMMER", contract.id
      r.add_field "KUNDENNUMMER", contract.user.id
      r.add_field "SWID", contract.rentable_item.id

      r.add_field "OBJEKT_NAME", contract.rentable_item.number
      r.add_field "OBJEKT_ADRESSE", contract.rentable_item.full_address
      r.add_field "OBJEKT_PREIS", number_to_currency(contract.price)
      r.add_field "OBJEKT_KAUTION", number_to_currency(contract.deposit)

      r.add_field "VERTRAGSBEGINN", I18n.l(contract.start_date)
      r.add_field "VERTRAGSENDE", I18n.l(contract.end_date)

      r.add_field "ZUSATZLEISTUNGEN", contract.billing_items.contract_monthly.map { |bi| "#{bi.name}: #{number_to_currency bi.price}" }.join(", ") || "Nein   "
    end

    rendered_odt.generate(tempfile)

    return odt_to_pdf(tempfile.path)
  end

  def odt_to_pdf(path)
    tempfile = Tempfile.new(['from_odf_report_odt', '.pdf'])

    Dir.mktmpdir do |dir|
      editor_command = 'libreoffice'
      editor_command = '/Applications/LibreOffice.app/Contents/MacOS/soffice' if Rails.env.development?
      system "#{editor_command} --headless --convert-to pdf --outdir #{dir} #{path}"
      system "mv #{dir}/*.pdf #{ tempfile.path }"
    end

    return tempfile.path
  end
end
