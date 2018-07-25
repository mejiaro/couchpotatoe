class CreateStylesheets < ActiveRecord::Migration
  def change
    create_table :stylesheets do |t|
      t.text :variables
      t.integer :themeable_id
      t.string :themeable_type
    end
  end
end
