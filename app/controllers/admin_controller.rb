class AdminController < ApplicationController
  before_filter :authenticate


  def featured
    @items = RentableItem.available(3.months.since).select { |r| r.images.any?  }

  end

  def update_featured
    RentableItem.all.each do |r|
      r.featured = false
      r.save
    end
    params[:feature].each do |id, _|
      r = RentableItem.find(id)
      r.featured = true
      r.save
    end
    redirect_to admin_featured_path
  end

  protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "username" && password == "password"
    end
  end
end
