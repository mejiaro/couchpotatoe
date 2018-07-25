class CreateTerms < ActiveRecord::Migration
  def self.up
    create_table :terms do |t|
      t.string :title
      t.text :description
      t.text :body
      t.integer :account_id      

      t.timestamps
    end
  end

  def self.down
    drop_table :terms
  end
end
