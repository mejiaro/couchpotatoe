class AddFailedOnToReceivables < ActiveRecord::Migration
  def change
    add_column :receivables, :failed_on, :datetime
  end
end
