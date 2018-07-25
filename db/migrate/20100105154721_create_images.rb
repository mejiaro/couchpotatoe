class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|

      t.string :image_file_name, :image_content_type
      t.integer :image_file_size
      t.references :attachable_image, :polymorphic => true
      t.references :account
      t.timestamps
    end

    create_table :image_translations do |t|
      t.string :locale
      t.references :image
      t.string :title
    end
  end

  def self.down
    drop_table :images
  end
end
