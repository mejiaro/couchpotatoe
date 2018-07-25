class ItemTypeAttributeTranslations < ActiveRecord::Base
  belongs_to :item_type_attribute
end

class AddValueToItemTypeAttributes < ActiveRecord::Migration
  def up
    add_column :item_type_attributes, :value, :string

    ItemTypeAttributeTranslations.all.each do |itat|
      ita = itat.item_type_attribute

      ita.value = itat.value

      ita.save!
    end
  end

  def down
   remove_column :item_type_attributes, :value, :string
  end
end
