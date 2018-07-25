class ContainerItemTranslations < ActiveRecord::Base
  belongs_to :container_item
end

class AddNameAndDescToContainerItems < ActiveRecord::Migration
  def up
    add_column :container_items, :name, :string
    add_column :container_items, :description, :text

    ContainerItemTranslations.all.each do |cit|
      ci = cit.container_item
      ci.name = cit.name
      ci.description = cit.description
      ci.save!
    end
  end

  def down
    remove_column :container_items, :name
    remove_column :container_items, :description
  end
end
