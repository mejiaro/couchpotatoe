class RentableItem < ActiveRecord::Base
  belongs_to :account
  has_many :contracts
  has_many :requests, dependent: :destroy
  has_many :images, { :as => :attachable_image }

  belongs_to :container_item

  geocoded_by :geocoding_address
  before_update :geocode

  has_and_belongs_to_many :item_type_attributes, { :join_table => :rentables_attributes }

  scope :available,  -> (range_end, range_start = Date.today) do
    where(blocked: false).select { |ri| (ri.earliest_available..ri.last_end_date).to_a.count > 30 && ri.earliest_available >= range_start && ri.earliest_available <= range_end }
  end

  attr_accessor :type

  def self.search(query)
    res = self
    res = res.available(2.months.since, Date.parse(query['start_date']) - 5.days) if query['start_date']
    res = res.select { |ri| ri.city == query['city'] } if query['city']
    return res
  end

  def start_dates
    if earliest_available.day == 1
      till = earliest_available
    else
      till = if !account.only_first_of_month && earliest_available.day <= 15
        Date.new(earliest_available.year, earliest_available.month, 15) 
      else
        earliest_available.next_month.beginning_of_month
      end
    end
    ((earliest_available)..till).to_a
  end

  def end_dates
    (first_end_date..last_end_date).to_a.select do |d|
      if account.only_first_of_month
        d.day == d.end_of_month.day
      else
        d.day == 14 || d.day == d.end_of_month.day
      end
    end
  end
  
  def first_end_date
    if account.at_least_one_year_rental_period && last_end_date >= 1.year.since
      start_dates.last + (1.year - 5.days)
    else
      start_dates.last + 25.days
    end
  end

  def price
    price_in_cents.nil? ? 0 : (price_in_cents / 100.0)
  end

  def price=(price_human)
    self.price_in_cents = BigDecimal.new(price_human) * 100.0
  end

  def deposit
    deposit_in_cents.nil? ? 0 : (deposit_in_cents / 100.0)
  end

  def deposit=(deposit_human)
    self.deposit_in_cents = BigDecimal.new(deposit_human) * 100.0
  end

  def geocoding_address
    self.full_address || container.full_address
  end

  def latlng
    [latitude, longitude]
  end

  def address
    read_attribute(:address).present? ? read_attribute(:address) : (container.present? ? container.address : nil)
  end

  def city
    read_attribute(:city).present? ? read_attribute(:city) : (container.present? ? container.city : nil)
  end

  def zip
    read_attribute(:zip).present? ? read_attribute(:zip) : (container.present? ? container.zip : nil)
  end

  def country
    read_attribute(:country).present? ? read_attribute(:country) : (container.present? ? container.country : nil)
  end

  def full_address
    [address, zip, city].all?(&:present?) && [address, zip, city].join(', ')
  end

  def display_name
    "#{number}, #{account.public_name}"
  end
  
  def display_name_with_container_items
    s = ""
    s += "#{container_item.display_name} > " if container_item.present?
    s += number
  end

  def container
    container_item.present? ? container_item : account
  end

  def ad_name
    read_attribute(:ad_name).present? ? read_attribute(:ad_name) : self.number
  end

  def room_count
    i, f = read_attribute(:room_count).to_i, read_attribute(:room_count).to_f
    i == f ? i : f
  end

  def earliest_available
    calculate_available_between
    @earliest_available
  end

  def last_end_date
    calculate_available_between
    @last_end_date
  end

 private

  def calculate_available_between
    if contract = contracts.valid.where('end_date >= ?', Date.today).order('end_date ASC').first
      @earliest_available = contract.end_date + 1.day
    else
      @earliest_available = Date.today
    end

    if contract = contracts.valid.where('start_date > ?', @earliest_available).order('start_date ASC').first
      @last_end_date = contract.start_date
    else
      @last_end_date = account.at_least_one_year_rental_period ? 24.months.since(@earliest_available) : 12.months.since(@earliest_available)
    end

    if read_attribute(:earliest_available).present? &&
       read_attribute(:earliest_available) > @earliest_available &&
       (read_attribute(:earliest_available) + 30.days) < @last_end_date
      @earliest_available = read_attribute(:earliest_available)
    end
  end
end
