class AddSignatureDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :signature_data, :text
  end
end
