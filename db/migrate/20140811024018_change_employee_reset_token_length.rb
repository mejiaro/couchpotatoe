class ChangeEmployeeResetTokenLength < ActiveRecord::Migration
  def up
    change_column :employees, :reset_password_token, :string, :limit => 255
  end

  def down
    change_column :employees, :reset_password_token, :string, :limit => 20
  end
end
