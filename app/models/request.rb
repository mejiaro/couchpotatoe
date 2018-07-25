require 'haml'

class Request < ActiveRecord::Base
  include FlagShihTzu

  belongs_to :contract
  belongs_to :user
  belongs_to :rentable_item
  belongs_to :accepted_by, class_name: 'User'

  has_one :account, through: :rentable_item

  has_flags 4 => :accepted,
            5 => :denied,
            6 => :enable_voting

  before_create :create_contract

  after_commit :notify_after_create, on: :create
  after_update :observe_accepted

  scope :pending, -> do
    pending_requests = self.where("contract_id IS NOT NULL AND #{ self.not_denied_condition }")
    pending_requests = self.where(id: pending_requests.map(&:id) - (Contract.where(id: pending_requests.map(&:contract_id)).valid.map(&:request).map(&:id)) )
    self.where(id: pending_requests.select { |r| r.contract.valid? && r.contract.start_date >= 1.month.ago }.map(&:id))
  end

  scope :archived, -> do
    self.where(id: self.all.map(&:id) - pending.map(&:id))
  end

  def progress
    prog = 0
    if self.accepted?
      prog += 10
    end
    if contract.deposit_paid?
      prog += 40
    end
    if contract.passport_verified?
      prog += 10
    end
    if contract.contract_verified?
      prog += 20
    end
    if contract.signed_contract
      prog += 15
    end
    if contract.passport
      prog += 5
    end
    return prog
  end

  def quality
    quality = (progress/2.0)
    quality += 10 if user.bank_data_present?
    quality += 10 if !user.signature_data.blank?
    quality += 20 if user.receivables.paid(false).none?
    quality + (11 - user.requests.where('requests.created_at >= ?', 1.week.ago).limit(10).count)
  end

 protected

  def create_contract
    self.contract = Contract.create!(user: self.user, rentable_item: self.rentable_item, start_date: self.start_date, end_date: self.end_date, price_in_cents: self.rentable_item.price_in_cents, deposit_in_cents: self.rentable_item.deposit_in_cents)
  end

  def notify_after_create
    RequestMailer.after_create_user(self).deliver_later
    RequestMailer.after_create_account(self).deliver_later
  end
  
  def observe_accepted
    contract.send_blank_contract if (self.accepted_changed? && self.accepted == true)
  end
end
