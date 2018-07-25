class AddAcceptedByToRequests < ActiveRecord::Migration
  def change
    add_reference :requests, :accepted_by, index: true
  end
end
