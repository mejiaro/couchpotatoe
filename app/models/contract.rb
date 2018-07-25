class Contract < ActiveRecord::Base
  include FlagShihTzu

  belongs_to :rentable_item
  has_one :account, through: :rentable_item

  belongs_to :user
  has_one :request

  has_many :receivables
  has_many :payments

  has_many :contract_billing_items
  has_many :billing_items, through: :contract_billing_items

  has_many :attachments, as: :attachable
  accepts_nested_attributes_for :attachments

  scope :valid, -> { where("(contracts.state = 'valid') OR #{ contract_verified_condition }") }
  scope :current_focus, -> { where('contracts.start_date < ? and contracts.end_date > ?', 1.months.since, 12.months.ago )}

  after_save :generate_contract
  before_create :copy_price_and_deposit

  scope :move_outs, (lambda do |month, year|
    query_date = Date.new(year, month, 1)

    ending_contracts = valid.where('end_date < ? and end_date > ?', query_date.end_of_month, query_date)

    ending_contracts.order('end_date asc')
  end)

  scope :move_ins, (lambda do |month, year|
    query_date = Date.new(year, month, 1)

    starting_contracts = valid.where('start_date < ? and start_date > ?', query_date.end_of_month, query_date)

    starting_contracts.order('end_date asc')
  end)

  scope :relocations_outbound, (lambda do |month, year|
    possible_move_outs = move_outs(month, year)
    possible_move_ins = move_ins(month, year) + move_ins(month == 12 ? 1 : month + 1, month == 12 ? year + 1 : year)
    possible_user_ids = possible_move_ins.map(&:user_id)
    rlcts = possible_move_outs.select { |pmo| possible_user_ids.include? pmo.user_id }
    self.where(id: rlcts.map(&:id))
  end)

  scope :relocations_inbound, (lambda do |month, year|
    possible_move_ins = move_ins(month, year)
    possible_move_outs = move_outs(month, year) + move_outs(month == 1 ? 12 : month - 1, month == 1 ? year - 1 : year)
    possible_user_ids = possible_move_outs.map(&:user_id)
    rlcts = possible_move_ins.select { |pmo| possible_user_ids.include? pmo.user_id }
    self.where(id: rlcts.map(&:id))
  end)

  validate :not_overlapping

  validate :range_must_be_positive

  has_flags 4 => :contract_verified,
            5 => :deposit_paid,
            6 => :passport_verified,
            7 => :blank_contract_sent,
            8 => :notified_about_user_signed,
            9 => :notified_about_landlord_signed

  def balance(options = {})
    items = if options[:current]
                receivables.current.to_a + payments.current.to_a
              else
                receivables.to_a + payments.to_a
              end

    in_cents = items.inject(0) { |acc, i| i.failed? ? acc : acc - i.debit_in_cents + i.credit_in_cents }

    if self.deposit_paid?
      in_cents += self.rentable_item.deposit_in_cents
    end

    BigDecimal(in_cents, 0) / 100
  end

  def receivables_sum
    in_cents = -self.receivables.not_failed.map(&:amount).sum
    BigDecimal(in_cents, 0) / 100
  end

  def payments_sum
    BigDecimal(payments_sum_in_cents, 0) / 100
  end

  def payments_sum_in_cents
    self.payments.reject { |p| p.receivable && p.receivable.failed? }.map(&:amount_in_cents).sum
  end

  def most_current_document(document_type)
    attachments.order('created_at DESC').where(document_type: document_type).first
  end

  def account
    rentable_item.account
  end

  def blank_contract
    self.attachments.where(document_type: 'blank_contract').order('created_at DESC').first
  end

  def signed_contract(all = false)
    types = ['signed_contract']
    types << 'signed_contract_account' if all
    self.attachments.where(document_type: types).order('created_at DESC').first
  end

  def passport
    self.attachments.where(document_type: 'passport').order('created_at DESC').first
  end

  def signed_contract=(file)
    self.attachments.build(document_type: 'signed_contract', document: file)
  end

  def passport=(file)
    self.attachments.build(document_type: 'passport', document: file)
  end

  def price_in_cents
    read_attribute(:price_in_cents) || rentable_item.price_in_cents
  end

  def price
    BigDecimal(price_in_cents) / 100
  end

  def daily_price
    Rational(price_in_cents / 30)
  end

  def deposit
    rentable_item.deposit
  end

  def verified?
    (self.state == 'valid') || (deposit_paid && contract_verified)
  end

  def generate_contract
    GenerateContractJob.perform_later(self)
  end

  def send_blank_contract
    if user.valid? && request.accepted? && !blank_contract_sent
      update_attribute(:blank_contract_sent, true)
      ContractMailer.after_create_user(self).deliver_later
      ContractMailer.after_create_account(self).deliver_later
    end
  end

  def follow_up?
    rentable_item.contracts.where('user_id = ? AND start_date > ? AND start_date < ?', user_id, end_date, end_date + 5.days).count > 0
  end

  def user_signed_notification
    if !notified_about_user_signed
      update_attribute(:notified_about_user_signed, true)
      ContractMailer.user_signed_user(self).deliver_later
      ContractMailer.user_signed_account(self).deliver_later
    end
  end

  def landlord_signed_notification
    if !notified_about_landlord_signed
      update_attribute(:notified_about_landlord_signed, true)
      ContractMailer.landlord_signed_tenant(self).deliver_later
      ContractMailer.landlord_signed_landlord(self).deliver_later
    end
  end

private

  def copy_price_and_deposit
    self.price_in_cents = self.rentable_item.price_in_cents
    self.deposit_in_cents = self.rentable_item.deposit_in_cents
  end

  def range_must_be_positive
    unless (end_date - start_date) > 0
      errors.add(:end_date, "Muss nach Vertragsstart sein.")
      errors.add(:start_date, "Muss vor Vertragsende sein.")
    end
  end

  def not_overlapping
    if self.rentable_item.present?
      self.rentable_item.contracts.valid.each do |c|
        unless (c.id == self.id) || c.new_record?
          if self.start_date >= c.start_date && self.start_date <= c.end_date
            errors.add(:start_date, "Liegt innerhalb eines anderen validen Vertrages.")
          end

          if self.end_date >= c.start_date && self.end_date <= c.end_date
            errors.add(:end_date, "Liegt innerhalb eines anderen validen Vertrages.")
          end

          if self.end_date >= c.end_date && self.start_date <= c.start_date
            errors.add(:end_date, "Umschließt einen gültigen Vertrag.")
            errors.add(:start_date, "Umschließt einen gültigen Vertrag.")
          end
        end
      end
    end
  end
end
