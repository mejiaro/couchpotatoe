require 'test_helper'

class RentableItemTest < ActiveSupport::TestCase
  test "ignores earliest_available set by user if the rentable_item is unavailable" do
    rentable_item = RentableItem.create!(earliest_available: Date.today)
    Contract.create!(state: 'valid',
                     start_date: 15.days.ago,
                     end_date: 45.days.since,
                     rentable_item: rentable_item)

    assert_equal 46.days.since.to_date, rentable_item.earliest_available
  end
end
