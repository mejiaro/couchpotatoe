class AddProgressToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :progress, :integer, default: 0
  end
end
