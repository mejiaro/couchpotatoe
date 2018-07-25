class AddKreditorAndDebitorToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :kreditoren_nr, :integer
    add_column :users, :debitoren_nr, :integer
  end

  def self.down
    remove_column :users, :kreditoren_nr
    remove_column :users, :debitoren_nr
  end
end
