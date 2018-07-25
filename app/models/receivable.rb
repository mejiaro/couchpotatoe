class Receivable < ActiveRecord::Base
  validates :amount, :contract_id, presence: true

  belongs_to :account
  belongs_to :contract
  belongs_to :billing_cycle

  has_many :payments

  has_one :user, through: :contract
  belongs_to :billable, polymorphic: true

  scope :bank_transfer, -> { joins(:contract => :user).where('users.direct_debit' => false) }
  scope :direct_debit, -> { joins(:contract => :user).where("users.direct_debit IS NULL OR users.direct_debit = ?", true) }

  scope :paid, ->(bool) do
    not_failed.where(is_paid: bool)
  end

  scope :failed, -> { where("receivables.failed_on IS NOT NULL") }
  scope :not_failed, -> { where("receivables.failed_on IS NULL") }
  scope :due, -> { where("receivables.due_since IS NOT NULL") - self.paid(true) }
  scope :current, -> { where('due_since <= ?', Date.today.end_of_month) }

  default_scope { joins(:contract).where('contracts.id IS NOT NULL').order('due_since asc') }

  before_create :associate_billing_cycle

  def price
    (BigDecimal(amount, 0) / 100)
  end

  def price=(amount_human)
    self.amount = BigDecimal.new(amount_human) * 100.0
  end

  def amount
    read_attribute(:amount) || (billable.present? ? billable.price_in_cents : 0)
  end

  def amount_paid
    BigDecimal(amount_paid_in_cents, 0) / 100
  end

  def amount_paid_in_cents
    self.payments.sum(:amount_in_cents)
  end

  def mandate_state
    if self.contract.start_date.month == billing_cycle.month && self.contract.end_date.month == billing_cycle.month
      'OOFF'
    elsif self.contract.start_date.month == billing_cycle.month
      'FRST'
    elsif self.contract.end_date.month == billing_cycle.month
      'FNAL'
    else
      'RCUR'
    end
  end

  def failed?
    failed_on.present?
  end

  def paid?
    is_paid?
  end

  def payment_reference
    pr = "#{ (billable && billable.name) || 'Miete' }"
    pr += " #{billing_cycle.month}/#{billing_cycle.year}" unless billable &&  billable.optional?
    pr += " (FEHLGESCHLAGEN)" if failed?
    return pr
  end

  def paid=(paid)
    if paid == 'true' && !paid?
      p = self.payments.build(amount_in_cents: self.amount, name: self.payment_reference, paid_on: Time.now, contract_id: contract_id)
      p.save!
      self.is_paid = true
      self.save

    elsif paid == 'false' && paid?
      self.payments.destroy_all
      self.is_paid = false
      self.save!
    end
  end

  def failed=(failed)
    if failed == 'true' && self.payments.sum(:amount_in_cents)
      self.payments.destroy_all
      self.failed_on = self.due_since
    end
  end

  def date
    due_since
  end

  def debit
    price
  end

  def debit_in_cents
    amount
  end

  def credit;0;end
  def credit_in_cents;0;end

  def self.mark_paid!
    Contract.all.each do |c|
      other_payments_sum = 0
      unpaid = c.receivables.not_failed.reject do |r|
        if r.payments.sum(:amount_in_cents) >= r.amount
          r.is_paid = true
          other_payments_sum += [0, r.payments.sum(:amount_in_cents) - r.amount].max
          r.save
        else
          r.is_paid = false
          r.save

          other_payments_sum += r.payments.sum(:amount_in_cents)

          false
        end
      end

      if unpaid.any?
        unpaid.sort_by!(&:due_since)

        other_payments = c.payments.where(receivable: nil)
        other_payments_sum += other_payments.sum(:amount_in_cents)

        while (unpaid.count > 0) && ((unpaid_receivable = unpaid.shift).amount <= other_payments_sum)
          other_payments_sum -= unpaid_receivable.amount
          unpaid_receivable.is_paid = true
          unpaid_receivable.save
        end
      end
    end
  end

  private

  def associate_billing_cycle
    unless self.billing_cycle.present?
      bi = contract.account.billing_cycles.find_or_initialize_by(year: due_since.year, month: due_since.month)
      bi.save
      self.billing_cycle = bi
    end
  end
end
