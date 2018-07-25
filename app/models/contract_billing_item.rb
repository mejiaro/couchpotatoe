class ContractBillingItem < ActiveRecord::Base
  belongs_to :contract
  belongs_to :billing_item
end
