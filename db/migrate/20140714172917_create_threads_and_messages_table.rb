class CreateThreadsAndMessagesTable < ActiveRecord::Migration
  def up
    create_table :subjects do |t|
      t.string :title
      t.references :user
      t.references :channel
      t.timestamps
    end

    create_table :messages do |t|
      t.text :text
      t.references :subject
      t.references :author, :polymorphic => true
      t.timestamps
    end
  end

  def down
    drop_table :subjects
    drop_table :messages
  end
end
