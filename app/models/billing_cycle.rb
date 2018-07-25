 class BillingCycle < ActiveRecord::Base
  has_many :receivables

  belongs_to :account
  has_many :billing_orders, as: :billable

  scope :last_year_ago_since_two_months, -> do
    in_range(Date.today.ago(12.months), Date.today)
  end

  scope :in_range, -> (beginning, ending) do
    where 'cast(concat(billing_cycles.year, "-", billing_cycles.month, "-", 1) as date) between ? and ?' , beginning, ending
  end

  scope :excluding_range,  -> (beginning, ending) do
    where('cast(concat(billing_cycles.year, "-", billing_cycles.month, "-", 1) as date) > ? OR cast(concat(billing_cycles.year, "-", billing_cycles.month, "-", 1) as date) < ?',
           ending, beginning)
  end

  def date
    Date.new(self.year, self.month, 1)
  end

  def start_date
    date
  end

  def end_date
    Date.new(self.year, self.month, -1)
  end

  def name
    [Date::MONTHNAMES[self.month], self.year].join(" ")
  end

  def to_sepa
    receivables = self.receivables.direct_debit.paid(false).all

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

  def self.update!
    Account.all.each do |account|
      account.contracts.valid.each do |contract|
        # delete receivables if contract start or end date where modified
        contract.receivables.joins(:billing_cycle).merge(BillingCycle.excluding_range(contract.start_date, contract.end_date)).destroy_all

        (contract.start_date..contract.end_date).map { |m| [m.year, m.month] }.uniq.each do |financial_month|
          billing_cycle = account.billing_cycles.find_or_initialize_by(year: financial_month[0], month: financial_month[1])
          billing_cycle.save!

          start_date = [billing_cycle.start_date, contract.start_date].max
          end_date = [billing_cycle.end_date, contract.end_date].min

          exact_days = (end_date.day - start_date.day + 1)

          days = exact_days < billing_cycle.end_date.day ? exact_days : 30

          rent = billing_cycle.receivables.where(contract_id: contract.id, billable: nil).first || billing_cycle.receivables.build(contract_id: contract.id)

          if rent.new_record?
            rent.amount = (days == 30) ? contract.price_in_cents : contract.daily_price * days
            rent.due_since = Date.new((billing_cycle.month == 1 ? billing_cycle.year - 1 : billing_cycle.year), (billing_cycle.month == 1 ? 12 : billing_cycle.month - 1), 15)
            rent.save!
          end

          contract.billing_items.each do |bi|
            receivable = billing_cycle.receivables.find_or_initialize_by(contract_id: contract.id, billable: bi)
            if receivable.new_record?
              receivable.amount = (days == 30) ? bi.price_in_cents :  bi.daily_price * days
              receivable.due_since = Date.new((billing_cycle.month == 1 ? billing_cycle.year - 1 : billing_cycle.year), (billing_cycle.month == 1 ? 12 : billing_cycle.month - 1), 15)
              receivable.save!
            end
          end
        end

        if account.billing_items.contract_end.any? && !contract.follow_up?
          account.billing_items.contract_end.each do |bi|
            unless contract.receivables.where(billable: bi).any?
              receivable = contract.receivables.build(due_since: contract.end_date, amount: bi.price_in_cents, billable: bi, billing_cycle: find_by(year: contract.end_date.year, month: contract.end_date.month))
              receivable.save!
            end
          end
        end
      end
    end
  end
end
