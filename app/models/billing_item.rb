class BillingItem < ActiveRecord::Base
  STATES = [:contract_monthly, :optional, :contract_end]

  include FlagShihTzu

  belongs_to :account

  has_flags 1 => STATES[0],
            2 => STATES[1],
            3 => STATES[2]
            
  def display_text
    "#{name} - #{"%8.2f" % price}€/Monat"
  end

  def mode
    STATES.find { |s| self.send(s) }
  end

  def mode=(state_index)
    STATES.each { |s| send("#{s}=", false) }
    send "#{ STATES[state_index.to_i]}=", true
  end

  def price
    price_in_cents.nil? ? 0 : (price_in_cents / 100.0)
  end

  def price=(price_human)
    self.price_in_cents = BigDecimal.new(price_human) * 100.0
  end

  def daily_price
    Rational(price_in_cents / 30)
  end
end
