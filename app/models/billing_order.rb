require 'zip'
class BillingOrder < ActiveRecord::Base
  include FlagShihTzu
  has_many :receivables

  belongs_to :billable, polymorphic: true

  belongs_to :account

  scope :current, -> do
    successful(false)
  end

  scope :successful, ->(bool=true) do
    if bool
      joins(:receivables).where('receivables.payed_on NOT IN (NULL, ?)', false)
    else
      joins(:receivables).where('receivables.payed_on' => [nil, false])
    end
  end

  scope :exported, -> do
    joins(:receivables).where('receivables.exported NOT IN (NULL, ?)', false)
  end

  scope :not_exported, -> do
    joins(:receivables).where('receivables.exported' => [nil, false])
  end

  has_flags 1 => :direct_debit,
            2 => :bank_transfer,
            3 => :order_exported


  def sum
    receivables.paid(false).map(&:price).sum
  end

  def relevance
    billable && -(billable.respond_to?(:date) ? billable.date : billable.start_date).to_time.to_i
  end

  def to_xml
    self.to_sepa
  end

  def to_zip
    ziptmpfile = Tempfile.new [billable.name, '.zip']
    Zip::File.open(ziptmpfile.path, Zip::File::CREATE) do |zipfile|
      self.receivables.paid(false).group_by { |r| r.mandate_state.to_sym }.each do |mandate_state, _|
        if sepa =  self.to_sepa(mandate_state)
          filename = "#{ mandate_state }.xml"
          tmpfile = Tempfile.new([mandate_state, '.xml'])
          File.open(tmpfile.path, 'w') { |f| f.write sepa }
          zipfile.add(filename, tmpfile.path)
        end
      end
    end
    ziptmpfile.path
  end

  def to_sepa(mandate_state = nil)

    receivables = mandate_state ? self.receivables.paid(false).select { |r| r.mandate_state.to_sym == mandate_state.to_sym } : self.receivables.paid(false).all
    sdd = SEPA::DirectDebit.new({
                                  name:       account.bank_account_owner,
                                  bic:        account.bic,
                                  iban:       account.iban,
                                  creditor_identifier: account.creditor_id
                                })

    receivables.each do |receivable|
      next unless receivable.amount > 0
      if receivable.contract.user.bank_data_present?
        remittance_information = format("Miete %04d-%02d Zimmer %s Vertrag %d Debitor %d - %s", receivable.billing_cycle.year, receivable.billing_cycle.month, receivable.contract.rentable_item.number, receivable.contract.id, receivable.contract.user.id, account.name)
        end_to_end = format("%04d-%02d-%d", receivable.billing_cycle.year, receivable.billing_cycle.month, receivable.contract.id)

        sdd.add_transaction({
                              name:                      receivable.contract.user.fullname,
                              bic:                       receivable.contract.user.bic,
                              iban:                      receivable.contract.user.iban,
                              amount:                    (BigDecimal.new(receivable.amount.to_s) / 100),
                              reference:                 end_to_end,
                              remittance_information:    remittance_information,
                              mandate_id:                receivable.contract.id,
                              mandate_date_of_signature: receivable.contract.created_at.to_date,
                              local_instrument:          'CORE',
                              sequence_type:             receivable.mandate_state,
                              requested_date:            Date.today + 5.days,
                              batch_booking:             true
                            })

      end
    end
    return !sdd.transactions.blank? && sdd.to_xml
  end
end
