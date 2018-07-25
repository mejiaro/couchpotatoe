class CreateChannels < ActiveRecord::Migration
  def up
    create_table :channels do |t|
      t.string :name
      t.references :account
    end
  end

  def down
    drop_table :channels
  end
end
