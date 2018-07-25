class CreateFloorPlans < ActiveRecord::Migration
  def self.up
    create_table :floor_plans do |t|

      t.string :plan_file_name, :plan_content_type
      t.integer :plan_file_size

      t.references :account, :container_item
      t.timestamps
    end

    create_table :floor_plan_translations do |t|
      t.string :locale
      t.references :floor_plan
      t.string :title
    end
  end

  def self.down
    drop_table :floor_plans
  end
end
