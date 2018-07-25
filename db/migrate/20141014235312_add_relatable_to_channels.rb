class AddRelatableToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :relatable_id, :integer
    add_column :channels, :relatable_type, :string
  end
end
