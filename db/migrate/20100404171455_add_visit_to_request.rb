class AddVisitToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :visit, :boolean
  end

  def self.down
    remove_column :requests, :visit
  end
end
