class AddFlagsToRequests < ActiveRecord::Migration
  def change
    change_table :requests do |t|
      t.integer  :flags, :null => false, :default => 0
    end
  end
end
