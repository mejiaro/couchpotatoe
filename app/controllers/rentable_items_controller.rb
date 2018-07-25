class RentableItemsController < ApplicationController
  def index
    @highlighted = params[:item]

    if @highlighted.present?
      ri = RentableItem.find(@highlighted)
      @query = {'city' => ri.city, 'start_date' => ri.earliest_available.to_s }
    elsif params[:search].present?
      @query = params[:search]
      cookies[:search] = @query.to_json
    elsif cookies[:search].present?
      @query = JSON.parse(cookies[:search])
    end

    filtered = @query.blank? ? RentableItem.available(2.months.since) : RentableItem.search(@query)
    @items = filtered.sort_by(&:earliest_available)

    if params[:price_from]
      @items.select! { |i| i.price > params[:price_from].to_f }
    end

    if params[:price_till]
      @items.select! { |i| i.price < params[:price_till].to_f }
    end

    @filter_tags = ''
    if !params[:filter_tags].blank?
      @filter_tags = params[:filter_tags] + ','
      @itas = params[:filter_tags].split(',').map { |ft| ItemTypeAttribute.find(ft) }.uniq
      @items.select! { |i| (i.item_type_attributes & @itas).length == @itas.length }
    end

    @cities = RentableItem.where(blocked: false).map(&:city).uniq
    @start_dates = (Date.today..2.months.since).select { |d| d == Date.today || d.day == 1 || d.day == 15 }

    if @related_account
      @items.select! { |i| i.account == @related_account }
    end
  end

  def show
    redirect_to rentable_items_path(item: params[:id])
  end

  def gallery
    @relevant_attributes = ItemTypeAttribute.most_used(13).to_a
    @rentable_item = RentableItem.find(params[:id])
    @active_tab = params[:active_tab] || 'details'
    render layout: nil
  end
end
