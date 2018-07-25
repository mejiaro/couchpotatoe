class ItemTypeAttribute < ActiveRecord::Base
  has_and_belongs_to_many :rentable_items, :join_table => :rentables_attributes
  has_and_belongs_to_many :container_items, :join_table => :containers_attributes

  def self.most_used(n=13)
    joins(:rentable_items)
    .group("rentables_attributes.item_type_attribute_id")
    .order("count(rentables_attributes.item_type_attribute_id) desc")
    limit(n)
  end
end
