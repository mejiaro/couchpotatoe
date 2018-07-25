class Payment < ActiveRecord::Base
  validates :amount_in_cents, :contract_id, presence: true

  belongs_to :receivable
  belongs_to :contract

  scope :current, -> { where('paid_on  <= ?', Date.today.end_of_month) }

  def amount
    amount_in_cents.nil? ? 0 : (amount_in_cents / 100.0)
  end

  def amount=(amount_human)
    self.amount_in_cents = BigDecimal.new(amount_human) * 100.0
  end

  def date
    paid_on
  end

  def credit
    amount
  end

  def credit_in_cents
    amount_in_cents
  end

  def failed?
    receivable && receivable.failed?
  end

  def debit; 0; end
  def debit_in_cents; 0; end


  def payment_reference
    pr = name
    pr += ' (FEHLGESCHLAGEN)' if receivable.present? && receivable.failed?
    return pr
  end
end
