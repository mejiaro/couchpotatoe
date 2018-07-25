class CreateLanguages < ActiveRecord::Migration
  def self.up
    create_table :languages do |t|
      t.string :locale_string
      t.timestamps
    end

    create_table :language_translations do |t|
      t.string :locale
      t.references :language
      t.string :name
    end
  end

  def self.down
    drop_table :languages
  end
end
