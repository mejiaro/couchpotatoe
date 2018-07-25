class AddPublicNameToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :public_name, :string
  end

  def self.down
    remove_column :accounts, :public_name
  end
end
