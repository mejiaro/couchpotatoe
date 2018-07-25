class AddPresentationOrderToImages < ActiveRecord::Migration
  def change
    add_column :images, :presentation_order, :integer
  end
end
