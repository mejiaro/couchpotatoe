class AddRsaToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rsa, :text
  end
end
