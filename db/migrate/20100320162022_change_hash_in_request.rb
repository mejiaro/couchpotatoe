class ChangeHashInRequest < ActiveRecord::Migration
  def self.up
    rename_column :requests, :hash, :id_hash
  end

  def self.down
    rename_column :requests, :id_hash, :hash
  end
end
