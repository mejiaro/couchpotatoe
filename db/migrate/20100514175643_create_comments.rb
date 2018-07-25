class CreateComments < ActiveRecord::Migration
  def self.up
       create_table :comments do |t|
      t.text :comment
      t.references :commentable, :polymorphic => true
      t.references :employee
      t.references :account
      t.timestamps
    end

    add_index :comments, :commentable_type
    add_index :comments, :commentable_id
    add_index :comments, :employee_id
  end

  def self.down
    drop_table :comments
  end
end
