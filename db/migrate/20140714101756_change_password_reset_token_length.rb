class ChangePasswordResetTokenLength < ActiveRecord::Migration
  def change
  	change_column :users, :reset_password_token, :string, :limit => 255
  end
end
