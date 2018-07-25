class LandingPagesController < ApplicationController

  def welcome
    if current_account
      redirect_to rentable_items_path
    else
      @welcome = true
      @start_dates = (Date.today..2.months.since).select { |d| d == Date.today || d.day == 1 || d.day == 15 }

      @cities = RentableItem.where(blocked: false).map(&:city).uniq

      @items = RentableItem.available(2.months.since).select { |r| r.images.any? && r.featured? }.sort_by(&:updated_at).reverse
    end
  end

  def imprint
  end

  def terms
    @terms = current_account.terms
  end

  def faq
  end
end
