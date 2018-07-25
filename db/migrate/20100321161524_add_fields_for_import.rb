class AddFieldsForImport < ActiveRecord::Migration
  def self.up
    add_column :users, :rented_until, :date
    add_column :users, :room_number, :string
    add_column :users, :active, :boolean
  end

  def self.down
    remove_column :users, :rented_until
    remove_column :users, :room_number
    remove_column :users, :active
  end
end
