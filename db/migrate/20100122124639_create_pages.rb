class CreatePages < ActiveRecord::Migration

  def self.up
    
    create_table :pages do |t|
      t.references :account
      t.boolean :main_menu, :homepage
      t.timestamps
    end

    create_table :page_translations do |t|
      t.references :page
      t.string :locale
      t.string :title, :menu_title, :keywords
      t.text :body
    end

  end

  def self.down
    drop_table :pages
  end
end
