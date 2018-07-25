class ContainerItem < ActiveRecord::Base
  acts_as_nested_set
  # acts_as_mappable

  has_many :images, :as => :attachable_image
  has_many :rentable_items

  belongs_to :parent, :class_name => "ContainerItem"
  belongs_to :account
  has_and_belongs_to_many :item_attributes, :join_table => :containers_attributes, :class_name => "ItemTypeAttribute"

  def display_name
    "#{parent.present? ? parent.name + ' > ' : nil}#{name}"
  end

  def address
    read_attribute(:address).present? ? read_attribute(:address) : (parent.present? ? parent.address : nil)
  end

  def city
    read_attribute(:city).present? ? read_attribute(:city) : (parent.present? ? parent.city : nil)
  end

  def zip
    read_attribute(:zip).present? ? read_attribute(:zip) : (parent.present? ? parent.zip : nil)
  end

  def country
    read_attribute(:country).present? ? read_attribute(:country) : (parent.present? ? parent.country : nil)
  end

  def full_address
    [address, zip, city].all?(&:present?) ? [address, zip, city].join(', ') : nil
  end


  # def geocode_address
  #   loc = Geokit::Geocoders::GoogleGeocoder.geocode(full_address)
  #   self.lat, self.lng = loc.lat, loc.lng
  # end


  def descendant_rentable_items
    self.leaf? ? self.rentable_items : self.leaves.map(&:rentable_items).flatten
  end
end
