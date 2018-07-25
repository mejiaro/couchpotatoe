class CreateLanDevices < ActiveRecord::Migration
  def self.up
    create_table :lan_devices do |t|
      t.string :mac, :ip, :identifier

      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :lan_devices
  end
end
