class CreateReceivables < ActiveRecord::Migration
  def self.up
    create_table :receivables do |t|
      t.string :text
      t.date :due_since, :payed_on
      t.references :account, :contract

      t.timestamps
    end
  end

  def self.down
    drop_table :receivables
  end
end
